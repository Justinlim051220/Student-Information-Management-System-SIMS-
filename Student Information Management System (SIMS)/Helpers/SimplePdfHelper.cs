using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;

namespace SIMS.Helpers
{
    /// <summary>
    /// Professional PDF helper for SIMS report exports.
    /// Uses only built-in PDF syntax, so no external NuGet package is required.
    /// All report types use the same tidy institutional layout:
    /// title bar, filter section, summary cards, coloured table header, alternating rows and footer.
    /// </summary>
    public static class SimplePdfHelper
    {
        private const int PageWidth = 842;
        private const int PageHeight = 595;
        private const int MarginLeft = 36;
        private const int MarginRight = 36;
        private const int TopY = 555;
        private const int BottomY = 46;
        private const int TableRowHeight = 18;

        private static readonly decimal OrangeR = 0.96m;
        private static readonly decimal OrangeG = 0.55m;
        private static readonly decimal OrangeB = 0.00m;

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
            List<string> pageContents = new List<string>();
            PdfPage page = NewPage(pageContents, title);

            RenderInfoSection(page, "Report Filter", filterTable);
            RenderSummaryCards(page, summaryTable);

            if (dateSummaryTable != null && dateSummaryTable.Rows.Count > 0)
            {
                RenderTable(pageContents, ref page, title, "Attendance Date Summary", dateSummaryTable, 8, 24);
            }

            RenderTable(pageContents, ref page, title,
                string.IsNullOrWhiteSpace(mainSectionTitle) ? "Report Details" : mainSectionTitle,
                mainTable,
                8,
                0);

            FinishPage(pageContents, page);
            return BuildPdf(pageContents);
        }

        private static PdfPage NewPage(List<string> pages, string title)
        {
            PdfPage page = new PdfPage();
            page.Content = new StringBuilder();
            page.Y = TopY;

            // top orange accent
            SetFill(page.Content, OrangeR, OrangeG, OrangeB);
            Rect(page.Content, 0, PageHeight - 14, PageWidth, 14, true);

            // title block
            SetFill(page.Content, 0.08m, 0.11m, 0.18m);
            Text(page.Content, "ONTI International University", 36, page.Y, 16, true);
            page.Y -= 22;
            Text(page.Content, Clean(title ?? "SIMS Report"), 36, page.Y, 14, true);
            page.Y -= 17;
            SetFill(page.Content, 0.39m, 0.45m, 0.55m);
            Text(page.Content, "Generated: " + DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"), 36, page.Y, 9, false);
            page.Y -= 24;

            return page;
        }

        private static void FinishPage(List<string> pages, PdfPage page)
        {
            if (page == null || page.Content == null) return;
            pages.Add(page.Content.ToString());
        }

        private static void AddFooter(string content, StringBuilder sb, int pageNumber, int totalPages)
        {
            // not used directly; footer is injected during final PDF object build so total pages is known.
        }

        private static void EnsureSpace(List<string> pages, ref PdfPage page, string title, int requiredHeight)
        {
            if (page.Y - requiredHeight >= BottomY) return;
            FinishPage(pages, page);
            page = NewPage(pages, title);
        }

        private static void RenderInfoSection(PdfPage page, string heading, DataTable table)
        {
            if (table == null || table.Rows.Count == 0) return;

            Text(page.Content, heading, MarginLeft, page.Y, 12, true);
            page.Y -= 14;

            int cardWidth = (PageWidth - MarginLeft - MarginRight - 12) / 2;
            int cardHeight = 30;
            int x = MarginLeft;
            int startY = page.Y;

            for (int i = 0; i < table.Rows.Count; i++)
            {
                if (i > 0 && i % 2 == 0)
                {
                    x = MarginLeft;
                    startY -= cardHeight + 8;
                }

                string label = Clean(Convert.ToString(table.Rows[i][0]));
                string value = Clean(Convert.ToString(table.Rows[i][1]));

                SetFill(page.Content, 0.97m, 0.98m, 1.00m);
                Rect(page.Content, x, startY - cardHeight + 4, cardWidth, cardHeight, true);
                SetStroke(page.Content, 0.88m, 0.91m, 0.96m);
                Rect(page.Content, x, startY - cardHeight + 4, cardWidth, cardHeight, false);

                SetFill(page.Content, 0.39m, 0.45m, 0.55m);
                Text(page.Content, Fit(label.ToUpperInvariant(), 32), x + 10, startY - 8, 7, true);
                SetFill(page.Content, 0.08m, 0.11m, 0.18m);
                Text(page.Content, Fit(value, 48), x + 10, startY - 22, 10, true);

                x += cardWidth + 12;
            }

            int rows = (int)Math.Ceiling(table.Rows.Count / 2.0);
            page.Y = page.Y - (rows * (cardHeight + 8)) - 8;
        }

        private static void RenderSummaryCards(PdfPage page, DataTable table)
        {
            if (table == null || table.Rows.Count == 0) return;

            Text(page.Content, "Report Summary", MarginLeft, page.Y, 12, true);
            page.Y -= 14;

            int totalWidth = PageWidth - MarginLeft - MarginRight;
            int cardGap = 10;
            int cardCount = Math.Min(4, table.Rows.Count);
            int cardWidth = (totalWidth - ((cardCount - 1) * cardGap)) / cardCount;
            int cardHeight = 42;
            int x = MarginLeft;

            for (int i = 0; i < table.Rows.Count; i++)
            {
                if (i > 0 && i % 4 == 0)
                {
                    x = MarginLeft;
                    page.Y -= cardHeight + 8;
                }

                string label = Clean(Convert.ToString(table.Rows[i][0]));
                string value = Clean(Convert.ToString(table.Rows[i][1]));

                SetFill(page.Content, 1.00m, 0.96m, 0.88m);
                Rect(page.Content, x, page.Y - cardHeight + 4, cardWidth, cardHeight, true);
                SetStroke(page.Content, 0.98m, 0.79m, 0.45m);
                Rect(page.Content, x, page.Y - cardHeight + 4, cardWidth, cardHeight, false);

                SetFill(page.Content, 0.62m, 0.33m, 0.00m);
                Text(page.Content, Fit(label.ToUpperInvariant(), 22), x + 10, page.Y - 10, 7, true);
                SetFill(page.Content, 0.08m, 0.11m, 0.18m);
                Text(page.Content, Fit(value, 18), x + 10, page.Y - 28, 14, true);

                x += cardWidth + cardGap;
            }

            int rows = (int)Math.Ceiling(table.Rows.Count / 4.0);
            page.Y -= (rows * (cardHeight + 8)) + 12;
        }

        private static void RenderTable(List<string> pages, ref PdfPage page, string reportTitle, string heading, DataTable table, int fontSize, int maxRows)
        {
            if (table == null || table.Rows.Count == 0)
            {
                EnsureSpace(pages, ref page, reportTitle, 40);
                Text(page.Content, heading, MarginLeft, page.Y, 12, true);
                page.Y -= 18;
                SetFill(page.Content, 0.39m, 0.45m, 0.55m);
                Text(page.Content, "No data available.", MarginLeft, page.Y, 10, false);
                page.Y -= 20;
                return;
            }

            EnsureSpace(pages, ref page, reportTitle, 64);
            Text(page.Content, heading, MarginLeft, page.Y, 12, true);
            page.Y -= 18;

            int[] widths = CalculateColumnWidths(table);
            DrawTableHeader(page, table, widths, fontSize);

            int rowLimit = maxRows > 0 ? Math.Min(maxRows, table.Rows.Count) : table.Rows.Count;
            for (int i = 0; i < rowLimit; i++)
            {
                EnsureSpace(pages, ref page, reportTitle, TableRowHeight + 24);

                // Repeat header after page break if the page is still near the top.
                if (page.Y > TopY - 80)
                {
                    Text(page.Content, heading + " (continued)", MarginLeft, page.Y, 11, true);
                    page.Y -= 16;
                    DrawTableHeader(page, table, widths, fontSize);
                }

                DrawTableRow(page, table, table.Rows[i], widths, fontSize, i % 2 == 0);
            }

            if (rowLimit < table.Rows.Count)
            {
                page.Y -= 4;
                SetFill(page.Content, 0.39m, 0.45m, 0.55m);
                Text(page.Content, "Only the first " + rowLimit.ToString(CultureInfo.InvariantCulture) + " rows are shown in the PDF. Export Excel/CSV for full details.", MarginLeft, page.Y, 8, false);
                page.Y -= 16;
            }

            page.Y -= 10;
        }

        private static void DrawTableHeader(PdfPage page, DataTable table, int[] widths, int fontSize)
        {
            int x = MarginLeft;
            int y = page.Y;

            SetFill(page.Content, OrangeR, OrangeG, OrangeB);
            Rect(page.Content, MarginLeft, y - TableRowHeight + 4, PageWidth - MarginLeft - MarginRight, TableRowHeight, true);

            SetFill(page.Content, 1.00m, 1.00m, 1.00m);
            for (int i = 0; i < table.Columns.Count; i++)
            {
                Text(page.Content, Fit(Clean(table.Columns[i].ColumnName).ToUpperInvariant(), Math.Max(4, widths[i] / 4)), x + 4, y - 8, Math.Max(6, fontSize - 1), true);
                x += widths[i];
            }

            page.Y -= TableRowHeight;
        }

        private static void DrawTableRow(PdfPage page, DataTable table, DataRow row, int[] widths, int fontSize, bool shade)
        {
            int x = MarginLeft;
            int y = page.Y;

            if (shade)
            {
                SetFill(page.Content, 0.98m, 0.99m, 1.00m);
                Rect(page.Content, MarginLeft, y - TableRowHeight + 4, PageWidth - MarginLeft - MarginRight, TableRowHeight, true);
            }

            SetStroke(page.Content, 0.90m, 0.92m, 0.95m);
            Rect(page.Content, MarginLeft, y - TableRowHeight + 4, PageWidth - MarginLeft - MarginRight, TableRowHeight, false);

            for (int i = 0; i < table.Columns.Count; i++)
            {
                string value = Clean(Convert.ToString(row[i]));
                string col = table.Columns[i].ColumnName;

                if (col.Equals("Status", StringComparison.OrdinalIgnoreCase) ||
                    col.Equals("Grade", StringComparison.OrdinalIgnoreCase) ||
                    col.Equals("Attendance %", StringComparison.OrdinalIgnoreCase))
                {
                    SetStatusColour(page.Content, value);
                }
                else
                {
                    SetFill(page.Content, 0.12m, 0.16m, 0.24m);
                }

                Text(page.Content, Fit(value, Math.Max(4, widths[i] / 4)), x + 4, y - 8, fontSize, false);
                x += widths[i];
            }

            page.Y -= TableRowHeight;
        }

        private static int[] CalculateColumnWidths(DataTable table)
        {
            int colCount = Math.Max(1, table.Columns.Count);
            int available = PageWidth - MarginLeft - MarginRight;
            int[] widths = new int[colCount];
            int[] weights = new int[colCount];

            int totalWeight = 0;
            for (int i = 0; i < colCount; i++)
            {
                string name = table.Columns[i].ColumnName;
                int weight = Math.Max(8, name.Length + 2);

                foreach (DataRow row in table.Rows)
                {
                    weight = Math.Max(weight, Math.Min(24, Clean(Convert.ToString(row[i])).Length + 2));
                }

                if (name.IndexOf("Name", StringComparison.OrdinalIgnoreCase) >= 0) weight += 8;
                if (name.IndexOf("Course", StringComparison.OrdinalIgnoreCase) >= 0) weight += 4;
                if (name.Equals("GPA", StringComparison.OrdinalIgnoreCase) || name.Equals("CGPA", StringComparison.OrdinalIgnoreCase)) weight = 8;
                if (name.Length <= 8 && colCount > 8) weight = Math.Min(weight, 10);

                weights[i] = weight;
                totalWeight += weight;
            }

            for (int i = 0; i < colCount; i++)
            {
                widths[i] = Math.Max(38, (int)Math.Floor((decimal)available * weights[i] / totalWeight));
            }

            int current = 0;
            foreach (int width in widths) current += width;
            while (current > available)
            {
                for (int i = 0; i < widths.Length && current > available; i++)
                {
                    if (widths[i] > 34)
                    {
                        widths[i]--;
                        current--;
                    }
                }
            }

            return widths;
        }

        private static byte[] BuildPdf(List<string> rawPages)
        {
            List<string> objects = new List<string>();
            objects.Add("<< /Type /Catalog /Pages 2 0 R >>");
            objects.Add("PAGES_PLACEHOLDER");
            objects.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
            objects.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>");

            List<int> pageObjectNumbers = new List<int>();
            int totalPages = rawPages.Count;

            for (int i = 0; i < rawPages.Count; i++)
            {
                int pageObjectNumber = objects.Count + 1;
                int contentObjectNumber = objects.Count + 2;
                pageObjectNumbers.Add(pageObjectNumber);

                string content = rawPages[i] + BuildFooter(i + 1, totalPages);
                byte[] contentBytes = Encoding.ASCII.GetBytes(content);

                objects.Add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + PageWidth + " " + PageHeight + "] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents " + contentObjectNumber + " 0 R >>");
                objects.Add("<< /Length " + contentBytes.Length.ToString(CultureInfo.InvariantCulture) + " >>\nstream\n" + content + "\nendstream");
            }

            StringBuilder kids = new StringBuilder();
            foreach (int objNum in pageObjectNumbers) kids.Append(objNum).Append(" 0 R ");
            objects[1] = "<< /Type /Pages /Kids [ " + kids + "] /Count " + pageObjectNumbers.Count.ToString(CultureInfo.InvariantCulture) + " >>";

            StringBuilder pdf = new StringBuilder();
            List<int> offsets = new List<int>();
            pdf.Append("%PDF-1.4\n");
            pdf.Append("%\u00e2\u00e3\u00cf\u00d3\n");

            for (int i = 0; i < objects.Count; i++)
            {
                offsets.Add(Encoding.ASCII.GetByteCount(pdf.ToString()));
                pdf.Append(i + 1).Append(" 0 obj\n");
                pdf.Append(objects[i]).Append("\nendobj\n");
            }

            int xrefOffset = Encoding.ASCII.GetByteCount(pdf.ToString());
            pdf.Append("xref\n");
            pdf.Append("0 ").Append(objects.Count + 1).Append("\n");
            pdf.Append("0000000000 65535 f \n");
            foreach (int offset in offsets) pdf.Append(offset.ToString("D10", CultureInfo.InvariantCulture)).Append(" 00000 n \n");
            pdf.Append("trailer\n");
            pdf.Append("<< /Size ").Append(objects.Count + 1).Append(" /Root 1 0 R >>\n");
            pdf.Append("startxref\n");
            pdf.Append(xrefOffset).Append("\n%%EOF");

            return Encoding.ASCII.GetBytes(pdf.ToString());
        }

        private static string BuildFooter(int pageNumber, int totalPages)
        {
            StringBuilder sb = new StringBuilder();
            SetStroke(sb, 0.90m, 0.92m, 0.95m);
            sb.Append("36 34 m 806 34 l S\n");
            SetFill(sb, 0.39m, 0.45m, 0.55m);
            Text(sb, "Generated by SIMS", 36, 22, 8, false);
            Text(sb, "Page " + pageNumber.ToString(CultureInfo.InvariantCulture) + " of " + totalPages.ToString(CultureInfo.InvariantCulture), 750, 22, 8, false);
            return sb.ToString();
        }

        private static void Text(StringBuilder sb, string text, int x, int y, int size, bool bold)
        {
            sb.Append("BT\n/").Append(bold ? "F2" : "F1").Append(" ").Append(size.ToString(CultureInfo.InvariantCulture)).Append(" Tf\n");
            sb.Append(x.ToString(CultureInfo.InvariantCulture)).Append(" ").Append(y.ToString(CultureInfo.InvariantCulture)).Append(" Td\n");
            sb.Append("(").Append(EscapePdfText(text)).Append(") Tj\nET\n");
        }

        private static void Rect(StringBuilder sb, int x, int y, int w, int h, bool fill)
        {
            sb.Append(x.ToString(CultureInfo.InvariantCulture)).Append(" ")
              .Append(y.ToString(CultureInfo.InvariantCulture)).Append(" ")
              .Append(w.ToString(CultureInfo.InvariantCulture)).Append(" ")
              .Append(h.ToString(CultureInfo.InvariantCulture)).Append(" re ")
              .Append(fill ? "f" : "S").Append("\n");
        }

        private static void SetFill(StringBuilder sb, decimal r, decimal g, decimal b)
        {
            sb.Append(r.ToString("0.###", CultureInfo.InvariantCulture)).Append(" ")
              .Append(g.ToString("0.###", CultureInfo.InvariantCulture)).Append(" ")
              .Append(b.ToString("0.###", CultureInfo.InvariantCulture)).Append(" rg\n");
        }

        private static void SetStroke(StringBuilder sb, decimal r, decimal g, decimal b)
        {
            sb.Append(r.ToString("0.###", CultureInfo.InvariantCulture)).Append(" ")
              .Append(g.ToString("0.###", CultureInfo.InvariantCulture)).Append(" ")
              .Append(b.ToString("0.###", CultureInfo.InvariantCulture)).Append(" RG\n");
        }

        private static void SetStatusColour(StringBuilder sb, string value)
        {
            value = value ?? "";
            if (value.IndexOf("Paid", StringComparison.OrdinalIgnoreCase) >= 0 ||
                value.IndexOf("Active", StringComparison.OrdinalIgnoreCase) >= 0 ||
                value.IndexOf("Present", StringComparison.OrdinalIgnoreCase) >= 0 ||
                value == "A+" || value == "A" || value == "A-" || value == "B+" || value == "B")
            {
                SetFill(sb, 0.05m, 0.45m, 0.22m);
            }
            else if (value.IndexOf("Pending", StringComparison.OrdinalIgnoreCase) >= 0 ||
                     value.IndexOf("Late", StringComparison.OrdinalIgnoreCase) >= 0 ||
                     value == "B-" || value == "C+" || value == "C")
            {
                SetFill(sb, 0.78m, 0.39m, 0.00m);
            }
            else if (value.IndexOf("Rejected", StringComparison.OrdinalIgnoreCase) >= 0 ||
                     value.IndexOf("Dropped", StringComparison.OrdinalIgnoreCase) >= 0 ||
                     value.IndexOf("Absent", StringComparison.OrdinalIgnoreCase) >= 0 ||
                     value == "C-" || value == "D" || value == "F")
            {
                SetFill(sb, 0.78m, 0.12m, 0.12m);
            }
            else
            {
                SetFill(sb, 0.12m, 0.16m, 0.24m);
            }
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

        private static string Fit(string text, int width)
        {
            text = Clean(text);
            if (width <= 0) return "";
            if (text.Length > width) text = width <= 3 ? text.Substring(0, width) : text.Substring(0, width - 3) + "...";
            return text;
        }

        private sealed class PdfPage
        {
            public StringBuilder Content { get; set; }
            public int Y { get; set; }
        }
    }
}
