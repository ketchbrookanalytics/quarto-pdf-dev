#show: template.with(
$if(title)$
  title: "$title$",
$endif$
$if(subtitle)$
  subtitle: "$subtitle$",
$endif$
$if(author)$
  author: "$author$",
$endif$
$if(author-email)$
  author-email: [$author-email$],
$endif$
$if(author-phone)$
  author-phone: "$author-phone$",
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(lof)$
  lof: $lof$,
$endif$
$if(lot)$
  lot: $lot$,
$endif$
$if(background-img)$
  background-img: "$background-img.path$",
$endif$
$if(header-logo)$
  header-logo: "$header-logo.path$",
$endif$
$if(main-color)$
  main-color: "$main-color$",
$endif$
)