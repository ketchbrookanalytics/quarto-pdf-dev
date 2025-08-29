// main project
#let template(
  title: "",
  subtitle: none,
  author: "",
  author-email: "",
  author-phone: "",
  toc: false,
  lof: false,
  lot: false,
  date: datetime.today().display(),
  background-img: none,
  header-logo: none,
  main-color: none,
  doc,
) = {



  // --------- Set Rules and Variables --------- //

  set document(author: author, title: title)

  // Set heading and body font families in variables
  let body-font = "Roboto"
  let title-font = "Roboto"

  // Set primary color in a variable
  let primary-color = rgb(main-color)

  // Create function to parse content and return string
  // Workaround for aggressive escape characters
  // See issue for details https://github.com/quarto-dev/quarto-cli/discussions/10223
  // Used to create mailto link to author-email
  let to-string(content) = {
    if content.has("text") {
      content.text
    } else if content.has("children") {
      content.children.map(to-string).join("")
    } else if content.has("body") {
      to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }

  // Set font family and size for body
  set text(font: body-font, 12pt)

  // Set font family, size, and color for headings
  show heading: set text(font: title-font, fill: primary-color)

  // Set heading numbering
  set heading(numbering: "1.1")

  // Set blocks to not allow breaking
  set block(breakable: false)

  // Set link style
  show link: it => underline(text(fill: primary-color, it))

  // Set numbered list indent, color, and numbering pattern
  set enum(indent: 1em, numbering: n => [#text(fill: primary-color, numbering("1.", n))])

  // Set unordered list indent and color
  set list(indent: 1em, marker: n => [#text(fill: primary-color, "•")])

  // Set table of contents, list of figures, and list of tables display
  show outline.entry: it => text(size: 12pt, weight: "regular",it)

  // Set code block background fill
  show raw.where(block: true): set block(fill: rgb("#dedede"))



  // --------- Create Title Page --------- //

  // Add Ketchbrook Analytics logo to the top of the page
  if header-logo != none {
    align(top)[
      #image(header-logo)
    ]
  }

  // Next, add the title, subtitle, and date of render
  align(center + horizon, text(font: title-font, 3em, weight: 700, title))
  v(2em, weak: true)
  if subtitle != none {
  align(center + horizon, text(font: title-font, 1.5em, weight: 700, subtitle))
  v(2em, weak: true)
  }
  align(center, text(1.1em, date))

  // Then, add the title page background image
  if background-img != none {
    align(horizon)[
      #image(background-img)
    ]
  }

  // Last, add the author details
  align(center)[
      #if author != "" {strong(author); linebreak();}
      #if author-email != "" {link("mailto:" + to-string(author-email)); linebreak();}
      #if author-phone != "" {author-phone; linebreak();}
    ]

  pagebreak()



  // --- Create Table of Contents, List of Figures, and List of Tables --- //

  // Create the Table of Contents
  // Only shown if set to TRUE in the `_quarto.yml` file
  if toc {
    outline()
  }

  // Create List of Figures
  // This uses an alternative approach to the outline function.
  // This searches for figures that are kind `quarto-float-fig`
  // See https://github.com/quarto-dev/quarto-cli/discussions/10223 for details
  if lof {
    outline(
    title: [List of Figures],
    target: figure.where(kind: "quarto-float-fig"),
    )
  }

  // Create List of Tables
  // This uses an alternative approach to the outline function.
  // This searches for figures that are kind `quarto-float-tbl`
  // See https://github.com/quarto-dev/quarto-cli/discussions/10223 for details
  if lot {
    outline(
    title: [List of Tables],
    target: figure.where(kind: "quarto-float-tbl"),
    )
  }

  pagebreak()



 // --------- Create Report Body --------- //

 // Set the page numbers at 1 to begin the report
  set page(
    numbering: "1",
    number-align: center,
  )

  // Set the header for the report body
  set page(
    header: [
      #set text(8pt)
      #emph()[#title #h(1fr) #author]
    ]
  )

  // Set the report body paragraph justification
  set par(justify: true)

  // Read in the report write up
  doc

}