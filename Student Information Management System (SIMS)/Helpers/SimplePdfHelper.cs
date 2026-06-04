using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;

namespace SIMS.Helpers
{
    /// <summary>
    /// Lightweight PDF helper for SIMS report exports.
    /// No external NuGet package is required.
    ///
    /// PDF export is intentionally summary-focused:
    /// - PDF: clean institutional summary, date summary, and condensed details.
    /// - Excel/CSV: full raw matrix/details.
    /// This prevents wide attendance date columns from merging together in PDF.
    /// </summary>
    public static class SimplePdfHelper
    {
        private const int PageWidth = 842;
        private const int PageHeight = 595;
        private const int MarginLeft = 36;
        private const int StartY = 552;
        private const int BottomY = 48;
        private const int LineGap = 14;
        private const int MaxLineChars = 132;

        public static byte[] CreatePdf(string title, DataTable table)
        {
            return CreateProfessionalReportPdf(title, null, null, null, table, "Report Details");
        }

        public static byte[] CreateProfessionalReportPdf(
            string title,
            DataTable filterTable,
            DataTable summaryTable,
            DataTable dateSummaryTable,
            DataTable mainTable,
            string mainSectionTitle)
        {
            List<List<PdfLine>> pages = BuildProfessionalPages(
                title,
                filterTable,
                summaryTable,
                dateSummaryTable,
                mainTable,
                mainSectionTitle);

            List<string> objects = new List<string>();
            objects.Add("<< /Type /Catalog /Pages 2 0 R >>");
            objects.Add("PAGES_PLACEHOLDER");
            objects.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
            objects.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>");

            List<int> pageObjectNumbers = new List<int>();

            for (int i = 0; i < pages.Count; i++)
            {
                int pageObjectNumber = objects.Count + 1;
                int contentObjectNumber = objects.Count + 2;
                pageObjectNumbers.Add(pageObjectNumber);

                string content = BuildPageContent(pages[i], i + 1, pages.Count);
                byte[] contentBytes = Encoding.ASCII.GetBytes(content);

                objects.Add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + PageWidth + " " + PageHeight + "] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents " + contentObjectNumber + " 0 R >>");
                objects.Add("<< /Length " + contentBytes.Length.ToString(CultureInfo.InvariantCulture) + " >>\nstream\n" + content + "\nendstream");
            }

            StringBuilder kids = new StringBuilder();
            foreach (int objNum in pageObjectNumbers)
            {
                kids.Append(objNum).Append(" 0 R ");
            }
            objects[1] = "<< /Type /Pages /Kids [ " + kids + "] /Count " + pageObjectNumbers.Count.ToString(CultureInfo.InvariantCulture) + " >>";

            return BuildPdf(objects);
        }

        private static List<List<PdfLine>> BuildProfessionalPages(
            string title,
            DataTable filterTable,
            DataTable summaryTable,
            DataTable dateSummaryTable,
            DataTable mainTable,
            string mainSectionTitle)
        {
            List<PdfLine> lines = new List<PdfLine>();
            lines.Add(new PdfLine("ONTI International University", 16, true));
            lines.Add(new PdfLine(title ?? "SIMS Report", 14, true));
            lines.Add(new PdfLine("Generated: " + DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"), 9, false));
            lines.Add(PdfLine.Blank());

            AppendInfoTable(lines, "Report Filter", filterTable);
            AppendInfoTable(lines, "Report Summary", summaryTable);

            if (dateSummaryTable != null && dateSummaryTable.Rows.Count > 0)
            {
                AppendDataTable(lines, "Attendance Date Summary", dateSummaryTable, true, 20);
            }

            AppendDataTable(lines, string.IsNullOrWhiteSpace(mainSectionTitle) ? "Report Details" : mainSectionTitle, mainTable, true, 28);

            if (lines.Count == 0)
            {
                lines.Add(new PdfLine("No data available.", 10, false));
            }

            return Paginate(lines);
        }

        private static void AppendInfoTable(List<PdfLine> lines, string heading, DataTable table)
        {
            if (table == null || table.Rows.Count == 0) return;

            lines.Add(new PdfLine(heading, 12, true));
            lines.Add(new PdfLine(new string('-', 100), 9, false));

            foreach (DataRow row in table.Rows)
            {
                string label = Clean(Convert.ToString(row[0]));
                string value = Clean(Convert.ToString(row[1]));
                lines.Add(new PdfLine(Pad(label, 24) + " : " + value, 10, false));
            }

            lines.Add(PdfLine.Blank());
        }

        private static void AppendDataTable(List<PdfLine> lines, string heading, DataTable table, bool repeatHeaderMarker, int maxRowsBeforeSoftBreak)
        {
            if (table == null || table.Rows.Count == 0) return;

            lines.Add(new PdfLine(heading, 12, true));

            int[] widths = CalculateWidths(table);
            string header = BuildTableLine(table, null, widths, true);
            string separator = new string('-', Math.Min(MaxLineChars, header.Length));

            lines.Add(new PdfLine(header, 8, true) { RepeatHeader = repeatHeaderMarker, HeaderText = header, SeparatorText = separator });
            lines.Add(new PdfLine(separator, 8, false));

            int rowCount = 0;
            foreach (DataRow row in table.Rows)
            {
                lines.Add(new PdfLine(BuildTableLine(table, row, widths, false), 8, false));
                rowCount++;

                if (maxRowsBeforeSoftBreak > 0 && rowCount % maxRowsBeforeSoftBreak == 0)
                {
                    lines.Add(PdfLine.Blank());
                }
            }

            lines.Add(PdfLine.Blank());
        }

        private static int[] CalculateWidths(DataTable table)
        {
            int colCount = table.Columns.Count;
            int[] widths = new int[colCount];

            for (int i = 0; i < colCount; i++)
            {
                widths[i] = Math.Min(22, Math.Max(8, table.Columns[i].ColumnName.Length + 2));
            }

            foreach (DataRow row in table.Rows)
            {
                for (int i = 0; i < colCount; i++)
                {
                    widths[i] = Math.Min(28, Math.Max(widths[i], Clean(Convert.ToString(row[i])).Length + 2));
                }
            }

            int available = MaxLineChars - ((colCount - 1) * 3);
            int total = 0;
            foreach (int width in widths) total += width;

            while (total > available && total > colCount * 8)
            {
                for (int i = 0; i < colCount && total > available; i++)
                {
                    if (widths[i] > 8)
                    {
                        widths[i]--;
                        total--;
                    }
                }
            }

            return widths;
        }

        private static string BuildTableLine(DataTable table, DataRow row, int[] widths, bool header)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < table.Columns.Count; i++)
            {
                if (i > 0) sb.Append(" | ");
                string value = header ? table.Columns[i].ColumnName : Convert.ToString(row[i]);
                sb.Append(Fit(Clean(value), widths[i]));
            }
            return TrimLine(sb.ToString(), MaxLineChars);
        }

        private static List<List<PdfLine>> Paginate(List<PdfLine> lines)
        {
            List<List<PdfLine>> pages = new List<List<PdfLine>>();
            List<PdfLine> current = new List<PdfLine>();
            int y = StartY;
            PdfLine lastHeader = null;

            foreach (PdfLine line in lines)
            {
                int gap = line.FontSize >= 12 ? 18 : LineGap;
                if (y - gap < BottomY && current.Count > 0)
                {
                    pages.Add(current);
                    current = new List<PdfLine>();
                    y = StartY;

                    if (lastHeader != null)
                    {
                        current.Add(new PdfLine(lastHeader.HeaderText, 8, true));
                        current.Add(new PdfLine(lastHeader.SeparatorText, 8, false));
                        y -= 2 * LineGap;
                    }
                }

                current.Add(line);
                y -= gap;

                if (line.RepeatHeader) lastHeader = line;
                if (line.FontSize >= 12) lastHeader = null;
            }

            if (current.Count > 0) pages.Add(current);
            if (pages.Count == 0) pages.Add(new List<PdfLine> { new PdfLine("No data available.", 10, false) });
            return pages;
        }

        private static string BuildPageContent(List<PdfLine> lines, int pageNumber, int totalPages)
        {
            StringBuilder sb = new StringBuilder();
            int y = StartY;

            foreach (PdfLine line in lines)
            {
                int fontSize = line.FontSize;
                int gap = fontSize >= 12 ? 18 : LineGap;
                string font = line.Bold ? "F2" : "F1";
                string text = line.Text ?? "";

                sb.Append("BT\n");
                sb.Append("/").Append(font).Append(" ").Append(fontSize.ToString(CultureInfo.InvariantCulture)).Append(" Tf\n");
                sb.Append(MarginLeft).Append(" ").Append(y.ToString(CultureInfo.InvariantCulture)).Append(" Td\n");
                sb.Append("(").Append(EscapePdfText(text)).Append(") Tj\n");
                sb.Append("ET\n");

                y -= gap;
            }

            sb.Append("BT\n/F1 8 Tf\n");
            sb.Append(MarginLeft).Append(" 24 Td\n");
            sb.Append("(Generated by SIMS) Tj\nET\n");

            sb.Append("BT\n/F1 8 Tf\n");
            sb.Append("730 24 Td\n");
            sb.Append("(Page ").Append(pageNumber.ToString(CultureInfo.InvariantCulture)).Append(" of ").Append(totalPages.ToString(CultureInfo.InvariantCulture)).Append(") Tj\nET");

            return sb.ToString();
        }

        private static byte[] BuildPdf(List<string> objects)
        {
            StringBuilder pdf = new StringBuilder();
            List<int> offsets = new List<int>();

            pdf.Append("%PDF-1.4\n");
            pdf.Append("%\u00e2\u00e3\u00cf\u00d3\n");

            for (int i = 0; i < objects.Count; i++)
            {
                offsets.Add(Encoding.ASCII.GetByteCount(pdf.ToString()));
                pdf.Append(i + 1).Append(" 0 obj\n");
                pdf.Append(objects[i]).Append("\n");
                pdf.Append("endobj\n");
            }

            int xrefOffset = Encoding.ASCII.GetByteCount(pdf.ToString());
            pdf.Append("xref\n");
            pdf.Append("0 ").Append(objects.Count + 1).Append("\n");
            pdf.Append("0000000000 65535 f \n");

            foreach (int offset in offsets)
            {
                pdf.Append(offset.ToString("D10", CultureInfo.InvariantCulture)).Append(" 00000 n \n");
            }

            pdf.Append("trailer\n");
            pdf.Append("<< /Size ").Append(objects.Count + 1).Append(" /Root 1 0 R >>\n");
            pdf.Append("startxref\n");
            pdf.Append(xrefOffset).Append("\n");
            pdf.Append("%%EOF");

            return Encoding.ASCII.GetBytes(pdf.ToString());
        }

        private static string EscapePdfText(string text)
        {
            text = Clean(text);
            text = text.Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");
            return text;
        }

        private static string Clean(string text)
        {
            if (text == null) return "";
            text = HttpUtility.HtmlDecode(text);
            text = text.Replace("✓", "Present").Replace("✗", "Absent");
            text = text.Replace("\r", " ").Replace("\n", " ").Replace("\t", " ");

            StringBuilder sb = new StringBuilder();
            foreach (char c in text)
            {
                sb.Append(c <= 127 ? c : '?');
            }
            return sb.ToString().Trim();
        }

        private static string Pad(string text, int width)
        {
            text = Fit(text, width);
            return text.PadRight(width);
        }

        private static string Fit(string text, int width)
        {
            if (string.IsNullOrEmpty(text)) return "".PadRight(width);
            if (text.Length > width) text = width <= 3 ? text.Substring(0, width) : text.Substring(0, width - 3) + "...";
            return text.PadRight(width);
        }

        private static string TrimLine(string text, int max)
        {
            if (string.IsNullOrEmpty(text)) return "";
            return text.Length <= max ? text : text.Substring(0, max - 3) + "...";
        }

        private sealed class PdfLine
        {
            public string Text { get; private set; }
            public int FontSize { get; private set; }
            public bool Bold { get; private set; }
            public bool RepeatHeader { get; set; }
            public string HeaderText { get; set; }
            public string SeparatorText { get; set; }

            public PdfLine(string text, int fontSize, bool bold)
            {
                Text = text;
                FontSize = fontSize;
                Bold = bold;
            }

            public static PdfLine Blank()
            {
                return new PdfLine(" ", 8, false);
            }
        }
    }
}
