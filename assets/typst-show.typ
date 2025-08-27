#show: template.with(
$if(title)$
  title: "$title$",
$endif$
$if(author)$
  author: "$author$",
$endif$
$if(background-img)$
  background-img: "$background-img.path$",
$endif$
$if(header-logo)$
  header-logo: "$header-logo.path$",
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
)