from __future__ import annotations

import html
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "RELATORIO_ENTREGA_FASE4.md"
HTML_OUT = ROOT / "RELATORIO_ENTREGA_FASE4.html"
DOCX_OUT = ROOT / "RELATORIO_ENTREGA_FASE4.docx"


CSS = """
body {
  font-family: Calibri, Arial, sans-serif;
  font-size: 11pt;
  line-height: 1.18;
  color: #1f2933;
  max-width: 760px;
  margin: 48px auto;
}
h1 {
  color: #12385f;
  font-size: 24pt;
  margin: 0 0 8px 0;
  padding-bottom: 8px;
  border-bottom: 3px solid #2e74b5;
}
h2 {
  color: #2e74b5;
  font-size: 16pt;
  margin: 26px 0 8px 0;
}
h3 {
  color: #1f4d78;
  font-size: 13pt;
  margin: 18px 0 6px 0;
}
p {
  margin: 0 0 8px 0;
}
ul, ol {
  margin-top: 4px;
  margin-bottom: 10px;
}
li {
  margin-bottom: 4px;
}
a {
  color: #1155cc;
}
code {
  font-family: Consolas, "Courier New", monospace;
  font-size: 9.5pt;
  background: #f2f4f7;
  padding: 1px 3px;
}
pre {
  background: #f2f4f7;
  border: 1px solid #d8dee9;
  border-left: 4px solid #2e74b5;
  padding: 10px 12px;
  white-space: pre-wrap;
  font-family: Consolas, "Courier New", monospace;
  font-size: 9.5pt;
  margin: 8px 0 12px 0;
}
.placeholder {
  border: 1px dashed #7b8794;
  background: #f8fafc;
  color: #52606d;
  padding: 18px;
  margin: 10px 0 16px 0;
  text-align: center;
  font-weight: bold;
}
.meta {
  background: #eef4fb;
  border-left: 4px solid #2e74b5;
  padding: 10px 12px;
  margin: 12px 0 18px 0;
}
"""


def inline_markdown(text: str) -> str:
    text = html.escape(text)
    text = re.sub(r"`([^`]+)`", lambda match: f"<code>{match.group(1)}</code>", text)
    text = re.sub(
        r"\[([^\]]+)\]\(([^)]+)\)",
        lambda match: f'<a href="{match.group(2)}">{match.group(1)}</a>',
        text,
    )
    return text


def convert_markdown(markdown: str) -> str:
    lines = markdown.splitlines()
    html_lines: list[str] = [
        "<!doctype html>",
        "<html>",
        "<head>",
        '<meta charset="utf-8">',
        "<title>Relatorio de Entrega - Tech Challenge Fase 4</title>",
        f"<style>{CSS}</style>",
        "</head>",
        "<body>",
    ]
    in_code = False
    code_buffer: list[str] = []
    in_list = False

    def close_list() -> None:
        nonlocal in_list
        if in_list:
            html_lines.append("</ul>")
            in_list = False

    for raw in lines:
        line = raw.rstrip()

        if line.startswith("```"):
            if not in_code:
                close_list()
                in_code = True
                code_buffer = []
            else:
                code = "\n".join(code_buffer).strip()
                if code.startswith("[INSERIR PRINT"):
                    html_lines.append(f'<div class="placeholder">{html.escape(code)}</div>')
                else:
                    html_lines.append(f"<pre>{html.escape(code)}</pre>")
                in_code = False
            continue

        if in_code:
            code_buffer.append(line)
            continue

        if not line.strip():
            close_list()
            continue

        if line.startswith("# "):
            close_list()
            html_lines.append(f"<h1>{inline_markdown(line[2:].strip())}</h1>")
        elif line.startswith("## "):
            close_list()
            html_lines.append(f"<h2>{inline_markdown(line[3:].strip())}</h2>")
        elif line.startswith("### "):
            close_list()
            html_lines.append(f"<h3>{inline_markdown(line[4:].strip())}</h3>")
        elif line.startswith("- "):
            if not in_list:
                html_lines.append("<ul>")
                in_list = True
            html_lines.append(f"<li>{inline_markdown(line[2:].strip())}</li>")
        else:
            close_list()
            if line.startswith(("Nome:", "RM:", "Username:", "Repositorio:", "Video de demonstracao:")):
                html_lines.append(f'<p class="meta">{inline_markdown(line)}</p>')
            else:
                html_lines.append(f"<p>{inline_markdown(line)}</p>")

    close_list()
    html_lines.extend(["</body>", "</html>"])
    return "\n".join(html_lines)


def main() -> None:
    html_doc = convert_markdown(SOURCE.read_text(encoding="utf-8"))
    HTML_OUT.write_text(html_doc, encoding="utf-8")
    subprocess.run(
        ["textutil", "-convert", "docx", "-output", str(DOCX_OUT), str(HTML_OUT)],
        check=True,
    )
    print(DOCX_OUT)


if __name__ == "__main__":
    main()
