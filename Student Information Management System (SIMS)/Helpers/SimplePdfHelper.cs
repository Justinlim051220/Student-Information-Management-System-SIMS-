using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;

namespace SIMS.Helpers
{
    public static class SimplePdfHelper
    {
        public static byte[] CreatePdf(string title, DataTable table)
        {
            List<string> lines = BuildLines(title, table);
            List<List<string>> pages = SplitPages(lines, 45);

            List<string> objects = new List<string>();
            objects.Add("<< /Type /Catalog /Pages 2 0 R >>");
            objects.Add("PAGES_PLACEHOLDER");
            objects.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");

            List<int> pageObjectNumbers = new List<int>();

            foreach (List<string> pageLines in pages)
            {
                int pageObjectNumber = objects.Count + 1;
                int contentObjectNumber = objects.Count + 2;
                pageObjectNumbers.Add(pageObjectNumber);

                string content = BuildPageContent(pageLines);
                byte[] contentBytes = Encoding.ASCII.GetBytes(content);

                objects.Add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Resources << /Font << /F1 3 0 R >> >> /Contents " + contentObjectNumber + " 0 R >>");
                objects.Add("<< /Length " + contentBytes.Length.ToString(CultureInfo.InvariantCulture) + " >>\nstream\n" + content + "\nendstream");
            }

            StringBuilder kids = new StringBuilder();
            foreach (int objNum in pageObjectNumbers)
            {
                kids.Append(objNum).Append(" 0 R ");
            }
            objects[1] = "<< /Type /Pages /Kids [ " + kids.ToString() + "] /Count " + pageObjectNumbers.Count.ToString(CultureInfo.InvariantCulture) + " >>";

            return BuildPdf(objects);
        }

        private static List<string> BuildLines(string title, DataTable table)
        {
            List<string> lines = new List<string>();
            lines.Add(title ?? "SIMS Report");
            lines.Add("Generated: " + DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"));
            lines.Add(" ");

            StringBuilder header = new StringBuilder();
            foreach (DataColumn col in table.Columns)
            {
                if (header.Length > 0) header.Append(" | ");
                header.Append(col.ColumnName);
            }
            lines.Add(TrimLine(header.ToString()));
            lines.Add(new string('-', 120));

            foreach (DataRow row in table.Rows)
            {
                StringBuilder rowText = new StringBuilder();
                for (int i = 0; i < table.Columns.Count; i++)
                {
                    if (i > 0) rowText.Append(" | ");
                    rowText.Append(Convert.ToString(row[i]));
                }
                lines.Add(TrimLine(rowText.ToString()));
            }

            return lines;
        }

        private static List<List<string>> SplitPages(List<string> lines, int linesPerPage)
        {
            List<List<string>> pages = new List<List<string>>();
            for (int i = 0; i < lines.Count; i += linesPerPage)
            {
                pages.Add(lines.GetRange(i, Math.Min(linesPerPage, lines.Count - i)));
            }
            if (pages.Count == 0) pages.Add(new List<string> { "No data" });
            return pages;
        }

        private static string BuildPageContent(List<string> lines)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("BT\n");
            sb.Append("/F1 10 Tf\n");
            sb.Append("12 TL\n");
            sb.Append("40 555 Td\n");

            foreach (string line in lines)
            {
                sb.Append("(").Append(EscapePdfText(line)).Append(") Tj\n");
                sb.Append("T*\n");
            }

            sb.Append("ET");
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
            if (text == null) return "";
            text = HttpUtility.HtmlDecode(text);
            text = text.Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");
            return RemoveNonAscii(text);
        }

        private static string RemoveNonAscii(string text)
        {
            StringBuilder sb = new StringBuilder();
            foreach (char c in text)
            {
                sb.Append(c <= 127 ? c : '?');
            }
            return sb.ToString();
        }

        private static string TrimLine(string text)
        {
            if (string.IsNullOrEmpty(text)) return "";
            return text.Length <= 145 ? text : text.Substring(0, 145) + "...";
        }
    }
}
