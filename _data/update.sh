#!/bin/bash
#
# Script to update list of publications by OTN members
# using Wikidata

curl 'https://query.wikidata.org/sparql?query=%23%20tool%3A%20scholia%0A%23defaultView%3ATable%0A%0APREFIX%20target%3A%20%3Chttp%3A%2F%2Fwww.wikidata.org%2Fentity%2FQ112326635%3E%0A%0ASELECT%0A%20%20%3FpublicationDate%0A%20%20%3Fwork%20%3FworkLabel%0A%20%20%3Fresearchers%20%0AWITH%20%7B%0A%20%20SELECT%20%0A%20%20%20%20(MIN(%3Fpublication_datetimes)%20AS%20%3Fpublication_datetime)%20%3Fwork%20%0A%20%20%20%20(GROUP_CONCAT(DISTINCT%20%3Fresearcher_label%3B%20separator%3D%27%7C%20%27)%20AS%20%3Fresearchers)%0A%20%20%20%20(CONCAT(%22..%2Fauthors%2F%22%2C%20GROUP_CONCAT(DISTINCT%20SUBSTR(STR(%3Fresearcher)%2C%2032)%3B%20separator%3D%22%7C%22))%20AS%20%3FresearchersUrl)%0A%20%20WHERE%20%7B%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%3Fresearcher%20(%20wdt%3AP108%20%7C%20wdt%3AP463%20%7C%20wdt%3AP1416%20)%20%2F%20wdt%3AP361*%20target%3A%20.%0A%20%20%20%20%3Fwork%20wdt%3AP50%20%3Fresearcher%20.%0A%20%20%20%20%3Fresearcher%20rdfs%3Alabel%20%3Fresearcher_label%20.%20FILTER%20(LANG(%3Fresearcher_label)%20%3D%20%27en%27)%0A%20%20%20%20OPTIONAL%20%7B%0A%20%20%20%20%20%20%3Fwork%20wdt%3AP577%20%3Fpublication_datetimes%20.%0A%20%20%20%20%7D%0A%20%20%7D%0A%20%20GROUP%20BY%20%3Fwork%0A%20%20ORDER%20BY%20DESC(%3Fpublication_datetime)%0A%20%20LIMIT%202000000%20%20%0A%7D%20AS%20%25results%0AWHERE%20%7B%0A%20%20INCLUDE%20%25results%0A%20%20BIND(xsd%3Adate(%3Fpublication_datetime)%20AS%20%3FpublicationDate)%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22en%2Cda%2Cde%2Ces%2Cfr%2Cjp%2Cnl%2Cnl%2Cru%2Czh%22.%20%7D%0A%7D%0AORDER%20BY%20DESC(%3FpublicationDate)%0A' -H "Accept: text/csv" > publications.csv


curl 'https://query.wikidata.org/sparql?query=SELECT%20%20%0A%3Fperson%20%3FpersonLabel%0A%28GROUP_CONCAT%28DISTINCT%20%3FtaxonName%20%3B%20separator%20%3D%20%22%20%7C%20%22%29%20AS%20%3FtaxonNames%29%0A%28CONCAT%28%27https%3A%2F%2Fscholia.toolforge.org%2Fauthor%2F%27%2CENCODE_FOR_URI%28REPLACE%28STR%28%3Fperson%29%2C%20%22.%2aQ%22%2C%20%22Q%22%29%29%29%20AS%20%3FscholiaURL%29%0AWHERE%20%7B%0A%20%20SELECT%20%0A%20%20DISTINCT%20%0A%20%20%3Fperson%20%3FpersonLabel%20%3FtaxonName%20%0A%20%20%20%20%20%20%20%20%20WHERE%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%3Fperson%20wdt%3AP463%20wd%3AQ112326635%20.%0A%20%20%20%20%20%20%20%20%20%20%20%3Fperson%20%5Ewdt%3AP50%20%3Fpaper%20.%0A%20%20%20%20%20%20%20%20%20%20%20%3Fpaper%20%28wdt%3AP921%7Cwdt%3AP4510%29%20%3FtaxonId%20.%0A%20%20%20%20%20%20%20%20%20%20%20%3FtaxonId%20wdt%3AP225%20%3FtaxonName%20.%0A%20%20%20%20%20%20%20%20%20%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cen%22.%20%7D%0A%20%20%20%20%20%20%20%20%20%7D%0A%20%20GROUP%20BY%20%3Fperson%20%3FpersonLabel%20%3FtaxonName%20%0A%20%20ORDER%20BY%20DESC%28%3FtaxonName%29%0A%7D%0AGROUP%20BY%20%3Fperson%20%3FpersonLabel%20%0AORDER%20BY%20ASC%28%3FpersonLabel%29%0A' -H "Accept: text/csv" > authors-to-taxa.csv


curl 'https://query.wikidata.org/sparql?query=SELECT%20%20%0A%3FtaxonId%20%3FtaxonName%20%0A%28GROUP_CONCAT%28DISTINCT%20%3FpersonLabel%20%3B%20separator%20%3D%20%22%20%7C%20%22%29%20AS%20%3Fpeople%29%0A%28CONCAT%28%27https%3A%2F%2Fscholia.toolforge.org%2Forganization%2FQ112326635%2Ftopic%2F%27%2CENCODE_FOR_URI%28REPLACE%28STR%28%3FtaxonId%29%2C%20%22.%2aQ%22%2C%20%22Q%22%29%29%29%20AS%20%3FscholiaURL%29%0AWHERE%20%7B%0A%20%20SELECT%20%0A%20%20DISTINCT%20%0A%20%20%3FtaxonId%20%3FtaxonName%20%3Fperson%20%3FpersonLabel%0A%20%20%20%20%20%20%20%20%20WHERE%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%3Fperson%20wdt%3AP463%20wd%3AQ112326635%20.%0A%20%20%20%20%20%20%20%20%20%20%20%3Fperson%20%5Ewdt%3AP50%20%3Fpaper%20.%0A%20%20%20%20%20%20%20%20%20%20%20%3Fpaper%20%28wdt%3AP921%7Cwdt%3AP4510%29%20%3FtaxonId%20.%0A%20%20%20%20%20%20%20%20%20%20%20%3FtaxonId%20wdt%3AP225%20%3FtaxonName%20.%0A%20%20%20%20%20%20%20%20%20%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cen%22.%20%7D%0A%20%20%20%20%20%20%20%20%20%7D%0A%20%20GROUP%20BY%20%3FtaxonId%20%3FtaxonName%20%3Fperson%20%3FpersonLabel%20%0A%20%20ORDER%20BY%20DESC%28%3FpersonLabel%29%0A%7D%0AGROUP%20BY%20%3FtaxonId%20%3FtaxonName%20%3Fpeople%0AORDER%20BY%20ASC%28%3FtaxonName%29%0A' -H "Accept: text/csv" > taxa-to-authors.csv

curl 'https://query.wikidata.org/sparql?query=SELECT%20%0A%20%20DISTINCT%20%3FtaxonId%20%3FtaxonName%20%3Fperson%20%3FpersonLabel%0AWHERE%20%7B%0A%20%20%3Fperson%20wdt%3AP463%20wd%3AQ112326635%20.%0A%20%20%3Fperson%20%5Ewdt%3AP50%20%3Fpaper%20.%0A%20%20%3Fpaper%20%28wdt%3AP921%7Cwdt%3AP4510%29%20%3FtaxonId%20.%0A%20%20%3FtaxonId%20wdt%3AP225%20%3FtaxonName%20.%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cen%22.%20%7D%0A%7D%0AORDER%20BY%20ASC%28%3FtaxonName%29' -H "Accept: text/csv" > taxon-to-author.csv

curl 'https://query.wikidata.org/sparql?query=SELECT%20DISTINCT%0A%20%20%3Fmethod%20%3FmethodLabel%0A%20%20%3Fperson%20%3FpersonLabel%0A%20%20%3Fwork%20%3FworkLabel%20%0A%20%20%3FpublicationDate%0AWITH%20%7B%0A%20%20SELECT%20DISTINCT%20%3Fperson%20WHERE%20%7B%0A%20%20%20%20%3Fperson%20wdt%3AP463%20wd%3AQ112326635%20.%0A%20%20%7D%20%0A%7D%20AS%20%25researchers%0AWHERE%20%7B%0A%20%20INCLUDE%20%25researchers%0A%0A%20%20%3Fwork%20wdt%3AP50%20%3Fperson%20%3B%0A%20%20%20%20%20%20%20%20wdt%3AP4510%20%3Fmethod%20.%0A%20%20OPTIONAL%20%7B%0A%20%20%20%20%3Fwork%20wdt%3AP577%20%3Fpublication_datetime%20.%0A%20%20%20%20BIND%28xsd%3Adate%28%3Fpublication_datetime%29%20AS%20%3FpublicationDate%29%0A%20%20%7D%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cen%2Cda%2Cde%2Ces%2Cfr%2Cjp%2Cnl%2Cno%2Cru%2Csv%2Czh%22.%20%7D%0A%7D%0AORDER%20BY%20DESC%28%3FpublicationDate%29%0A' -H "Accept: text/csv" > method-to-author.csv

