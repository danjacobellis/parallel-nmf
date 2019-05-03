# Notebook to PDF (as a document)

`jupyter-nbconvert report.ipynb --to pdf --template template.tplx`

# Notebook to PDF (as a slide deck)

`jupyter-nbconvert presentation.ipynb --to slides --post serve --ServePostProcessor.port=9998 --ServePostProcessor.ip="0.0.0.0"`

Then, in a browser, go to http://70.114.202.148:9998.

To convert to pdf, add ?print-pdf to URL, i.e.

http://70.114.202.148:9998/presentation.slides.html?print-pdf

Then print to pdf.

