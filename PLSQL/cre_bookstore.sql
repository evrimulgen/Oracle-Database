declare
l_xml XMLTYPE;
l_clob CLOB;

begin
l_xml:=XMLTYPE('<bookstore>
<book category="cooking">
<title lang="en">Everyday Italian</title>
<author>Giada De Laurentiis</author>
<year>2005</year>
<price>30.00</price>
</book>
<book category="children">
<title lang="en">Harry Potter</title>
<author>J K. Rowling</author>
<year>2005</year>
<price>29.99</price>
</book>
<book category="web">
<title lang="en">XQuery Kick Start</title>
<author>James McGovern</author>
<author>Per Bothner</author>
<author>Kurt Cagle</author>
<author>James Linn</author>
<author>Vaidyanathan Nagarajan</author>
<year>2003</year>
<price>49.99</price>
</book>
<book category="web" cover="paperback">
<title lang="en">Learning XML</title>
<author>Erik T. Ray</author>
<year>2003</year>
<price>39.95</price>
</book>
</bookstore>');

select XMLQuery('copy $tmp := $p modify insert node 
<Pages>260 </Pages>
as last into $tmp/bookstore/book
return $tmp
'
passing l_xml as "p"
returning CONTENT).getCLobVal() into l_clob from dual;
DBMS_OUTPUT.PUT_LINE(l_clob);


end;

CREATE table book
(
 book_xml XMLTYPE
 );


INSERT INTO book
VALUES(XMLTYPE('<bookstore>
<book category="cooking">
<title lang="en">Everyday Italian</title>
<author>Giada De Laurentiis</author>
<year>2005</year>
<price>30.00</price>
</book>
<book category="children">
<title lang="en">Harry Potter</title>
<author>J K. Rowling</author>
<year>2005</year>
<price>29.99</price>
</book>
<book category="web">
<title lang="en">XQuery Kick Start</title>
<author>James McGovern</author>
<author>Per Bothner</author>
<author>Kurt Cagle</author>
<author>James Linn</author>
<author>Vaidyanathan Nagarajan</author>
<year>2003</year>
<price>49.99</price>
</book>
<book category="web" cover="paperback">
<title lang="en">Learning XML</title>
<author>Erik T. Ray</author>
<year>2003</year>
<price>39.95</price>
</book>
</bookstore>'));


begin



end





select b.book_xml.getClobVal() from book b;

select XMLQUERY('for $i in /bookstore
                  for $j in $i/book 
                  where $j/price > 30  return <Details> {$j/title}{$j/year}</Details>' PASSING b.book_xml RETURNING CONTENT).getClobval() as "DATA"
from book b;
---Insert a node

select XMLQUERY('copy $tmp := $p modify insert node
                       <Docks> 3 </Docks> as last 
                       into $tmp/bookstore/book[1] return $tmp' PASSING b.book_xml as "p" RETURNING CONTENT).getClobval() as "DATA"
from book b;










