<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Benjamin W. Broersma <bw@broersma.com, License: CC-0 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	 xmlns:eml="urn:oasis:names:tc:evs:schema:eml"
	 xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	 xmlns:kr="http://www.kiesraad.nl/extensions"
	 xmlns:rg="http://www.kiesraad.nl/reportgenerator"
	 xmlns:xal="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"
	 xmlns:xnl="urn:oasis:names:tc:ciq:xsdschema:xNL:2.0"
	 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	 xsi:schemaLocation="urn:oasis:names:tc:evs:schema:eml 510-count-v5-0.xsd http://www.kiesraad.nl/extensions kiesraad-eml-extensions.xsd">
<xsl:output omit-xml-declaration="yes" encoding="UTF-8"/>
<!--http://stackoverflow.com/a/7523245-->
<!--how this works: it checks if the text contains the replace search value, if not return text, else get substring-before+replacement+recursive call self with substring-after as text-->
<xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text"
select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<xsl:template match="eml:EML">
{
  "municipality": "GM<xsl:value-of select="eml:ManagingAuthority/eml:AuthorityIdentifier/@Id"/>",
  "date": "<xsl:value-of select="eml:Count/eml:Election/eml:ElectionIdentifier/kr:ElectionDate"/>",
  "election": "<xsl:value-of select="eml:Count/eml:Election/eml:ElectionIdentifier/@Id"/>",
  "electionName": "<xsl:value-of select="eml:Count/eml:Election/eml:ElectionIdentifier/eml:ElectionName"/>",
  "features":[
    <xsl:apply-templates select="eml:Count/eml:Election/eml:Contests/eml:Contest/eml:ReportingUnitVotes"/>
]}
</xsl:template>
<xsl:template match="eml:ReportingUnitVotes">
  {"type":"Feature","properties":{
      "Stembureau": <xsl:value-of select="substring-after(eml:ReportingUnitIdentifier/@Id,'::SB')"/>,
      "Adres": "<xsl:call-template name="replace-string">
                          <xsl:with-param name="text" select="substring-before(substring-after(eml:ReportingUnitIdentifier,'(postcode: '), ')')"/>
                          <xsl:with-param name="replace" select="' '" />
                          <xsl:with-param name="with" select="''"/>
                      </xsl:call-template>",
      "Locatie": "<xsl:value-of select="substring-after(eml:ReportingUnitIdentifier/@Id,'::')"/>",
      "description": "<xsl:call-template name="replace-string">
                          <xsl:with-param name="text" select="eml:ReportingUnitIdentifier"/>
                          <xsl:with-param name="replace" select="'&quot;'" />
                          <xsl:with-param name="with" select="'\&quot;'"/>
                      </xsl:call-template>",
      "Geldige stemmen": <xsl:value-of select="eml:TotalCounted"/>,
      "Opgeroepen": <xsl:value-of select="eml:Cast"/>,
      "Ongeldig": <xsl:value-of select="eml:RejectedVotes[@ReasonCode='ongeldig']"/>,
      "Blanco": <xsl:value-of select="eml:RejectedVotes[@ReasonCode='blanco']"/>,

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='geldige stempassen']">
      "Geldige stempassen": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='geldige stempassen']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Geldige stempassen": 0,
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='geldige volmachtbewijzen']">
      "Geldige volmachtbewijzen": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='geldige volmachtbewijzen']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Geldige volmachtbewijzen": 0,
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='geldige kiezerspassen']">
      "Geldige kiezerspassen": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='geldige kiezerspassen']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Geldige kiezerspassen": 0,
        </xsl:otherwise>
      </xsl:choose>

      "Toegelaten kiezers": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='toegelaten kiezers']"/>,
      "Meer getelde stembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='meer getelde stembiljetten']"/>,
      "Minder getelde stembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='minder getelde stembiljetten']"/>,

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='meegenomen stembiljetten']">
      "Meegenomen stembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='meegenomen stembiljetten']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Meegenomen stembiljetten": 0,
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='te weinig uitgereikte stembiljetten']">
      "Te weinig uitgereikte stembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='te weinig uitgereikte stembiljetten']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Te weinig uitgereikte stembiljetten": 0,
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='te veel uitgereikte stembiljetten']">
      "Te veel uitgereikte stembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='te veel uitgereikte stembiljetten']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Te veel uitgereikte stembiljetten": 0,
        </xsl:otherwise>
      </xsl:choose>

      "Geen verklaring": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='geen verklaring']"/>,
      "Andere verklaring": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='andere verklaring']"/>,

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='te veel briefstembiljetten']">
      "Te veel briefstembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='te veel briefstembiljetten']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Te veel briefstembiljetten": 0,
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes[@ReasonCode='geen briefstembiljetten']">
      "Geen briefstembiljetten": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='geen briefstembiljetten']"/>,
        </xsl:when>
        <xsl:otherwise>
      "Geen briefstembiljetten": 0,
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="eml:UncountedVotes"><!--EML502-->
      "Opkomst": <xsl:value-of select="eml:UncountedVotes[@ReasonCode='toegelaten kiezers'] + eml:UncountedVotes[@ReasonCode='meer getelde stembiljetten'] - eml:UncountedVotes[@ReasonCode='minder getelde stembiljetten']"/>,
      "Opkomstpercentage": <xsl:value-of select="format-number((eml:UncountedVotes[@ReasonCode='toegelaten kiezers'] + eml:UncountedVotes[@ReasonCode='meer getelde stembiljetten'] - eml:UncountedVotes[@ReasonCode='minder getelde stembiljetten']) div eml:Cast * 100,'0.00')"/>,
        </xsl:when>
        <xsl:otherwise><!--TK2012 case, pre-EML502-->
      "Opkomst": <xsl:value-of select="eml:TotalCounted + eml:RejectedVotes[@ReasonCode='blanco'] - eml:RejectedVotes[@ReasonCode='ongeldig']"/>,
      "Opkomstpercentage": <xsl:value-of select="format-number((eml:TotalCounted + eml:RejectedVotes[@ReasonCode='blanco'] - eml:RejectedVotes[@ReasonCode='ongeldig']) div eml:Cast * 100,'0.00')"/>,
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="eml:Selection[eml:AffiliationIdentifier]"/>
    }
  }
  <xsl:if test="position() != last()">,</xsl:if>
</xsl:template>
<xsl:template match="eml:Selection[eml:AffiliationIdentifier]">
      "<xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="eml:AffiliationIdentifier/eml:RegisteredName"/>
          <xsl:with-param name="replace" select="'&quot;'" />
          <xsl:with-param name="with" select="'\&quot;'"/>
      </xsl:call-template>": <xsl:value-of select="eml:ValidVotes"/><xsl:if test="position() != last()">,</xsl:if>
</xsl:template>
</xsl:stylesheet>
