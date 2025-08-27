// main project
#let template(
  title: "",
  subtitle: none,
  author: "",
  toc: true,
  lof: false,
  lot: false,
  date: datetime.today().display(),
  background-img: none,
  header-logo: none,
  main-color: "2f70c8",
  alpha: 60%,
  doc,
) = {
  set document(author: author, title: title)

  // Save heading and body font families in variables.
  let body-font = "Roboto"
  let title-font = "Roboto"

  // Set colors
  let primary-color = rgb(main-color) // alpha = 100%
  // change alpha of primary color
  let secondary-color = color.mix(color.rgb(100%, 100%, 100%, alpha), primary-color, space:rgb)

  // Set body font family.
  set text(font: body-font, 12pt)
  show heading: set text(font: title-font, fill: primary-color)

  //heading numbering
  set heading(numbering: "1.1")

  // Set link style
  show link: it => underline(text(fill: primary-color, it))

  //numbered list colored
  set enum(indent: 1em, numbering: n => [#text(fill: primary-color, numbering("1.", n))])

  //unordered list colored
  set list(indent: 1em, marker: n => [#text(fill: primary-color, "•")])

  // display of outline entries
  show outline.entry: it => text(size: 12pt, weight: "regular",it)


    // KA Header.
  // Logo at top right if given
  if header-logo != none {
    align(top)[
      #image(header-logo)
    ]
  }

  align(center + horizon, text(font: title-font, 3em, weight: 700, title))
  v(2em, weak: true)
  if subtitle != none {
  align(center + horizon, text(font: title-font, 2em, weight: 700, subtitle))
  v(2em, weak: true)
  }
  align(center, text(1.1em, date))

    // Title page.
  // Logo at top right if given
  if background-img != none {
    align(horizon)[
      #image(background-img)
    ]
  }

  // Author and other information.
  align(center)[
      #if author != "" {strong(author); linebreak();}

    ]

  pagebreak()

  if toc {
    outline()
  }

  if lof {
    outline(
    title: [List of Figures],
    target: figure.where(kind: image),
    )
  }

  if lot {
    outline(
    title: [List of Tables],
    target: figure.where(kind: table),
    )
  }

  // bibliography("works.bib")

  // Table of contents.
  set page(
    numbering: "1",
    number-align: center,
    )


  // Main body.
  set page(
    header: [#emph()[#title #h(1fr) #author]]
  )
  set par(justify: true)

  doc

}