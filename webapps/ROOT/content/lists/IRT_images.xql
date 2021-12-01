xquery version "3.1" encoding "UTF-8";
declare namespace t = "http://www.tei-c.org/ns/1.0";

let $col := collection('epidoc/?select=*.xml')
return
          for $graphic in $col//t:graphic
          let $root := $graphic/ancestor::t:TEI
          let $idno :=  $root//t:idno[@type='filename']/text()
          let $url := string($graphic/@url)
          let $caption := replace(normalize-space($graphic/t:desc), ';', '.')
          let $repository := replace(normalize-space($root//t:repository/text()), ';', '.')
          let $ancientFindspot := replace(normalize-space(string-join($root//t:provenance[@type='found']//t:placeName[@type='ancientFindspot']/text(), ' ')), ';', '.')
          let $monuList := replace(normalize-space(string-join($root//t:provenance[@type='found']//t:placeName[@type='monuList']/text(), ' ')), ';', '.')
          
           return
           ('', $idno, '; ', $url, '; ', $caption, '; ', $repository, '; ', $ancientFindspot, '; ', $monuList, '
           ')