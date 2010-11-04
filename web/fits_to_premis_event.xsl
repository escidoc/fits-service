<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
		version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:premis="info:lc/xmlns/premis-v2"
		xmlns:mets="http://www.loc.gov/METS/"
		xmlns:mods="http://www.loc.gov/mods/v3"
		xmlns:fits="http://hul.harvard.edu/ois/xml/ns/fits/fits_output"
		>
	
	<xsl:output
			method="xml"
			omit-xml-declaration="no"
			encoding="UTF-8"
			indent="yes"
			/>
	
	<!-- parameters from Alfresco -->
	<xsl:param name="objectIdentifierValue"/>
	<xsl:param name="fitsEventValue"/>
	<xsl:param name="timestamp"/>
	
	<xsl:template match="fits:fits">
		<premis:event xsi:schemaLocation="premis2.xsd">
			<!-- give some identifier for the event - will use the same for the object -->
			<premis:eventIdentifier>
				<premis:eventIdentifierType>
					<xsl:text>Alfresco</xsl:text>
				</premis:eventIdentifierType>
				<premis:eventIdentifierValue>
					<xsl:value-of select="$fitsEventValue"/>
				</premis:eventIdentifierValue>
			</premis:eventIdentifier>
			
			<!-- type of event -->
			<premis:eventType>
				<xsl:text>FITS</xsl:text>
			</premis:eventType>
			
			<!-- time of event -->
			<!-- FITS @timestamp is not in good format, so maybe pass in timestamp value from Alfresco -->
			<premis:eventDateTime>
				<xsl:value-of select="@timestamp"/>
			</premis:eventDateTime>
			
			<!-- additional information -->
			<premis:eventDetail>
				<xsl:text>Object put through FITS for identification</xsl:text>
			</premis:eventDetail>
			
			<!-- outcomes of FITS event -->
			<!-- want to record conflicts and failures in well-formedness and validity -->
			<xsl:apply-templates select="fits:identification[@status='CONFLICT']" mode="outcome"/>
			<xsl:apply-templates select="fits:fileinfo/fits:*[@status='CONFLICT']" mode="outcome"/>
			<xsl:apply-templates select="fits:filestatus/fits:*[.='false']" mode="outcome"/>
			
			<!-- link back to object -->
			<premis:linkingObjectIdentifier>
				<premis:linkingObjectIdentifierType><!-- hdl etc. --></premis:linkingObjectIdentifierType>
				<premis:linkingObjectIdentifierValue>
					<xsl:value-of select="$objectIdentifierValue"/>
				</premis:linkingObjectIdentifierValue>
				<premis:linkingObjectRole>
					<xsl:text>source</xsl:text>
				</premis:linkingObjectRole>
			</premis:linkingObjectIdentifier>
			
		</premis:event>
	</xsl:template>
	
	<!-- outcomes of FITS event worth recording -->

	<xsl:template match="fits:identification" mode="outcome">
		<premis:eventOutcomeInformation>
			<premis:eventOutcome>
				<xsl:text>identification conflict</xsl:text>
			</premis:eventOutcome>
			<premis:eventOutcomeDetail>
				<premis:eventOutcomeDetailNote>
					<xsl:text>Conflicting format identifications found</xsl:text>
				</premis:eventOutcomeDetailNote>
				<!-- keep copy of conflicting identifications -->
				<premis:eventOutcomeDetailExtension>
					<xsl:copy-of select="."/>
				</premis:eventOutcomeDetailExtension>
			</premis:eventOutcomeDetail>
		</premis:eventOutcomeInformation>
	</xsl:template>
	
	<xsl:template match="fits:well-formed" mode="outcome">
		<premis:eventOutcomeInformation>
			<premis:eventOutcome>
				<xsl:text>not well formed</xsl:text>
			</premis:eventOutcome>
			<premis:eventOutcomeDetail>
				<premis:eventOutcomeDetailNote>
					<xsl:text>The digital object is not a well-formed instance of the identified format</xsl:text>
				</premis:eventOutcomeDetailNote>
				<premis:eventOutcomeDetailExtension>
					<xsl:copy-of select="."/>
				</premis:eventOutcomeDetailExtension>
			</premis:eventOutcomeDetail>
		</premis:eventOutcomeInformation>
	</xsl:template>

	<xsl:template match="fits:valid" mode="outcome">
		<premis:eventOutcomeInformation>
			<premis:eventOutcome>
				<xsl:text>not valid</xsl:text>
			</premis:eventOutcome>
			<premis:eventOutcomeDetail>
				<premis:eventOutcomeDetailNote>
					<xsl:text>The digital object is not valid according to the format</xsl:text>
				</premis:eventOutcomeDetailNote>
				<premis:eventOutcomeDetailExtension>
					<xsl:copy-of select="."/>
				</premis:eventOutcomeDetailExtension>
			</premis:eventOutcomeDetail>
		</premis:eventOutcomeInformation>
	</xsl:template>

	<xsl:template match="fits:*" mode="outcome">
		<premis:eventOutcomeInformation>
			<premis:eventOutcome>
				<xsl:value-of select="concat(local-name(), ' conflict')"/>
			</premis:eventOutcome>
			<premis:eventOutcomeDetail>
				<premis:eventOutcomeDetailNote>
					<xsl:text>Conflicting values have been found for a fits:fileinfo element</xsl:text>
				</premis:eventOutcomeDetailNote>
				<premis:eventOutcomeDetailExtension>
					<xsl:copy-of select="."/>
				</premis:eventOutcomeDetailExtension>
			</premis:eventOutcomeDetail>
		</premis:eventOutcomeInformation>
	</xsl:template>
	
</xsl:stylesheet>
