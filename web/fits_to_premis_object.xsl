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
	<xsl:param name="originalName"/>
	<xsl:param name="contentLocationValue"/>
	<xsl:param name="compositionLevel">0</xsl:param>
	<xsl:param name="fitsEventValue"/>
	
	<xsl:template match="fits:fits">
		<premis:object xsi:schemaLocation="premis2.xsd">
			<!-- need to work out how to generate file identifier -->
			<premis:objectIdentifier>
				<premis:objectIdentifierType><!-- hdl? --></premis:objectIdentifierType>
				<premis:objectIdentifierValue>
					<xsl:value-of select="$objectIdentifierValue"/>
				</premis:objectIdentifierValue>
			</premis:objectIdentifier>
			
			<!-- preservation level - given by policy -->
			<premis:preservationLevel>
				<premis:preservationLevelValue>full</premis:preservationLevelValue>
				<premis:preservationLevelRole>requirement</premis:preservationLevelRole>
				<premis:preservationLevelRationale>blah blah</premis:preservationLevelRationale>
				<premis:preservationLevelDateAssigned>2010-07-12</premis:preservationLevelDateAssigned>
			</premis:preservationLevel>
			
			<!-- base significant properties on type of metadata, e.g. image, text etc. and any file status elements -->
			<xsl:apply-templates select="fits:metadata|fits:filestatus" mode="significant_properties"/>
			
			<!-- object characteristics -->
			<premis:objectCharacteristics>
				
				<!-- composition level not evident from FITS output, could be passed in from Alfresco -->
				<premis:compositionLevel>
					<xsl:value-of select="$compositionLevel"/>
				</premis:compositionLevel>
				
				<!-- use MD5 checksum from OIS File Information -->
				<xsl:apply-templates select="fits:fileinfo/fits:md5checksum" mode="fixity"/>
				
				<!-- size in bytes, non-repeatable -->
				<xsl:apply-templates select="fits:fileinfo/fits:size[1]" mode="size"/>
				
				<!-- file format - start with those with externalIdentifiers -->
				<xsl:apply-templates select="fits:identification/fits:identity[fits:externalIdentifier]" mode="format"/>
				<xsl:apply-templates select="fits:identification/fits:identity[not(fits:externalIdentifier)]" mode="format"/>
				
				<!-- creating application -->
				<xsl:apply-templates select="fits:fileinfo" mode="creating_application"/>
				
				<!-- not doing anything with encrypted stuff just now, so don't need inhibitor information -->
				<xsl:comment>
					<premis:inhibitors>
						<premis:inhibitorType><!-- encryption algorithm  --></premis:inhibitorType>
						<premis:inhibitorTarget><!-- All content, Function: Play etc. --></premis:inhibitorTarget>
						<premis:inhibitorKey><!-- decryption key --></premis:inhibitorKey>
					</premis:inhibitors>
				</xsl:comment>
				
				<!-- could dump FITS metadata here -->
				<premis:objectCharacteristicsExtension>
					<xsl:apply-templates select="fits:metadata" mode="object_characteristics_extension"/>
				</premis:objectCharacteristicsExtension>
			</premis:objectCharacteristics>
			
			<!-- original name of file has to come from Alfresco, as FITS is given a temporary name -->
			<premis:originalName>
				<xsl:value-of select="$originalName"/>
			</premis:originalName>

			<!-- storage -->
			<premis:storage>
				<premis:contentLocation>
					<!-- give URI of content -->
					<premis:contentLocationType>
						<xsl:text>URI</xsl:text>
					</premis:contentLocationType>
					<premis:contentLocationValue>
						<xsl:value-of select="$contentLocationValue"/>
					</premis:contentLocationValue>
				</premis:contentLocation>
				<premis:storageMedium>
					<xsl:text>hard disk</xsl:text>
				</premis:storageMedium>
			</premis:storage>
			
			<!-- have no use for environment just now -->
			<xsl:comment>
				<premis:environment>
					<premis:environmentCharacteristic><!-- recommended, minimum etc. --></premis:environmentCharacteristic>
					<premis:environmentPurpose><!-- render, edit etc. --></premis:environmentPurpose>
					<premis:environmentNote><!-- free text description --></premis:environmentNote>
					<premis:dependency>
						<premis:dependencyName><!-- name of dependency --></premis:dependencyName>
						<premis:dependencyIdentifier>
							<premis:dependencyIdentifierType><!-- URI etc. --></premis:dependencyIdentifierType>
							<premis:dependencyIdentifierValue><!-- given URI --></premis:dependencyIdentifierValue>						
						</premis:dependencyIdentifier>
					</premis:dependency>
					<premis:software>
						<premis:swName><!-- Adobe Photoshop etc --></premis:swName>
						<premis:swVersion><!-- 6.0, 2000 etc. --></premis:swVersion>
						<premis:swType><!-- renderer, ancilliary, operating system etc. --></premis:swType>
						<premis:swOtherInformation><!-- instructions etc. --></premis:swOtherInformation>
						<premis:swDependency><!-- GNU gcc &gt;= 2.7.2 --></premis:swDependency>
					</premis:software>
					<premis:hardware>
						<premis:hwName><!-- Pentium III etc. --></premis:hwName>
						<premis:hwType><!-- processor, memory etc. --></premis:hwType>
						<premis:hwOtherInformation><!-- 32Mb minimum etc. --></premis:hwOtherInformation>
					</premis:hardware>
					<premis:environmentExtension><!-- embedded  XML --></premis:environmentExtension>
				</premis:environment>
			</xsl:comment>
			
			<!-- have no use for digital signatures just now -->
			<xsl:comment>
				<premis:signatureInformation>
					<premis:signature>
						<premis:signatureEncoding><!-- Base64 --></premis:signatureEncoding>
						<premis:signer><!-- agent or agent identifier --></premis:signer>
						<premis:signatureMethod><!-- DSA SHA1 etc. --></premis:signatureMethod>
						<premis:signatureValue><!-- encrypted value --></premis:signatureValue>
						<premis:signatureValidationRules><!-- how to perform validation --></premis:signatureValidationRules>
						<premis:signatureProperties><!-- details of signature --></premis:signatureProperties>
						<premis:keyInformation><!-- embedded XML --></premis:keyInformation>
						<premis:signatureInformationExtension><!-- embedded XML --></premis:signatureInformationExtension>
					</premis:signature>
				</premis:signatureInformation>
			</xsl:comment>
			
			<!-- relationship etc. information will get added later -->
			<xsl:comment>
				<premis:relationship>
					<premis:relationshipType><!-- structural, derivation etc. --></premis:relationshipType>
					<premis:relationshipSubType><!-- has sibling, is part of etc. --></premis:relationshipSubType>
					<premis:relatedObjectIdentification>
						<premis:relatedObjectIdentifierType><!-- hdl etc. --></premis:relatedObjectIdentifierType>
						<premis:relatedObjectIdentifierValue><!-- identifier value --></premis:relatedObjectIdentifierValue>
						<premis:relatedObjectSequence><!-- page number etc. --></premis:relatedObjectSequence>
					</premis:relatedObjectIdentification>
					<premis:relatedEventIdentification>
						<premis:relatedEventIdentifierType><!-- --></premis:relatedEventIdentifierType>
						<premis:relatedEventIdentifierValue><!-- --></premis:relatedEventIdentifierValue>
						<premis:relatedEventSequence><!-- 1, 2, 3 etc. --></premis:relatedEventSequence>
					</premis:relatedEventIdentification>
				</premis:relationship>
			</xsl:comment>
			
			<!-- putting digital object through FITS is an event -->
			<premis:linkingEventIdentifier>
				<premis:linkingEventIdentifierType>
					<xsl:text>Alfresco</xsl:text>
				</premis:linkingEventIdentifierType>
				<premis:linkingEventIdentifierValue>
					<xsl:value-of select="$fitsEventValue"/>
				</premis:linkingEventIdentifierValue>
			</premis:linkingEventIdentifier>
			
			<xsl:comment>
				<premis:linkingIntellectualEntityIdentifier>
					<premis:linkingIntellectualEntityIdentifierType><!-- URI etc. --></premis:linkingIntellectualEntityIdentifierType>
					<premis:linkingIntellectualEntityIdentifierValue><!-- --></premis:linkingIntellectualEntityIdentifierValue>
				</premis:linkingIntellectualEntityIdentifier>
				
				<premis:linkingRightsStatementIdentifier>
					<premis:linkingRightsStatementIdentifierType><!-- URI etc. --></premis:linkingRightsStatementIdentifierType>
					<premis:linkingRightsStatementIdentifierValue><!-- --></premis:linkingRightsStatementIdentifierValue>
				</premis:linkingRightsStatementIdentifier>
			</xsl:comment>
		</premis:object>
	</xsl:template>
	
	<!-- significant properties -->
	<xsl:template match="fits:metadata|fits:filestatus" mode="significant_properties">
		<xsl:for-each select="descendant::fits:*[@toolname and @toolversion]">
			<premis:significantProperties>
				<premis:significantPropertiesType>
					<xsl:value-of select="local-name()"/>
				</premis:significantPropertiesType>
				<premis:significantPropertiesValue>
					<xsl:apply-templates/>
				</premis:significantPropertiesValue>
				<premis:significantPropertiesExtension>
					<fits:tool toolname="{@toolname}" toolversion="{@toolversion}"/>
				</premis:significantPropertiesExtension>
			</premis:significantProperties>
		</xsl:for-each>
	</xsl:template>
	
	<!-- work out composition level from extension, perhaps? -->
	<xsl:template match="EXTENSION" mode="composition_level">
		<premis:compositionLevel>0</premis:compositionLevel>
	</xsl:template>
	
	<!-- fixity information (MD5) -->
	<xsl:template match="fits:md5checksum" mode="fixity">
		<premis:fixity>
			<premis:messageDigestAlgorithm>MD5</premis:messageDigestAlgorithm>
			<premis:messageDigest>
				<xsl:apply-templates/>
			</premis:messageDigest>
			<premis:messageDigestOriginator>
				<xsl:value-of select="concat(@toolname, ' (', @toolversion, ')')"/>
			</premis:messageDigestOriginator>
		</premis:fixity>
	</xsl:template>
	
	<!-- size of object in bytes -->
	<xsl:template match="fits:size" mode="size">
		<premis:size>
			<xsl:apply-templates/>
		</premis:size>
	</xsl:template>
	
	<!-- file format -->
	<xsl:template match="fits:identity" mode="format">
		<premis:format>
			<premis:formatDesignation>
				<!-- use @format for mandatory format name -->
				<premis:formatName>
					<xsl:value-of select="@format"/>
				</premis:formatName>
				<!-- use version if supplied -->
				<xsl:if test="fits:version">
					<premis:formatVersion>
						<xsl:apply-templates select="fits:version"/>
					</premis:formatVersion>
				</xsl:if>
			</premis:formatDesignation>
			<!-- use externalIdentifier for formatRegistry -->
			<xsl:apply-templates select="fits:externalIdentifier[1]" mode="format"/>
			<!-- mention if there are conflicting format identities -->
			<xsl:if test="parent::fits:identification/@status='CONFLICT'">
				<premis:formatNote>
					<xsl:text>Conflicting format identities found.</xsl:text>
				</premis:formatNote>
			</xsl:if>
			<!-- list tools behind this format -->
			<premis:formatNote>
				<xsl:text>Tools providing this format identification:</xsl:text>
				<xsl:apply-templates select="fits:tool" mode="format"/>
			</premis:formatNote>
		</premis:format>
	</xsl:template>
	
	<!-- information from PRONOM via DROID -->
	<xsl:template match="fits:externalIdentifier" mode="format">
		<premis:formatRegistry>
			<premis:formatRegistryName>
				<xsl:value-of select="concat(@toolname, ' (', @toolversion, ')')"/>
			</premis:formatRegistryName>
			<premis:formatRegistryKey>
				<xsl:apply-templates/>
			</premis:formatRegistryKey>
			<!-- put type of external identifier into registry role -->
			<premis:formatRegistryRole>
				<xsl:value-of select="@type"/>
			</premis:formatRegistryRole>
		</premis:formatRegistry>
	</xsl:template>
	
	<!-- tool providing format identification -->
	<xsl:template match="fits:tool" mode="format">
		<xsl:text>
</xsl:text>
		<xsl:value-of select="concat(@toolname, ' (', @toolversion, ')')"/>
	</xsl:template>
	
	<!-- creating application -->
	<xsl:template match="fits:fileinfo" mode="creating_application">
		<!-- loop over all creatingApplicationName elements -->
		<xsl:for-each select="fits:creatingApplicationName | fits:creatingApplicationVersion[not(../fits:creatingApplicationName)] | fits:created[not(../fits:creatingApplicationName) and not(../fits:creatingApplicationVersion)]">
			<xsl:variable name="name_toolname" select="@toolname"/>
			<xsl:variable name="name_toolversion" select="@toolversion"/>
			<xsl:variable name="names_agree" select="not(@status='CONFLICT')"/>
			<xsl:variable name="name">
				<xsl:if test="local-name() = 'creatingApplicationName'">
					<xsl:apply-templates/>
				</xsl:if>
			</xsl:variable>

			<!-- loop over all creatingApplicationVersion elements which come from same tool as name, or are not in conflict -->
			<!-- if there are none, then use the current node from the loop outside this one, so that this loop has at least one iteration -->
			<xsl:for-each select="../fits:creatingApplicationVersion[(@toolname = $name_toolname and @toolversion = $name_toolversion) or $names_agree or not(@status = 'CONFLICT')] | current()[not(../fits:creatingApplicationVersion[(@toolname = $name_toolname and @toolversion = $name_toolversion) or $names_agree or not(@status = 'CONFLICT')])]">
				<xsl:variable name="version_toolname" select="@toolname"/>
				<xsl:variable name="version_toolversion" select="@toolversion"/>
				<xsl:variable name="versions_agree" select="not(@status='CONFLICT')"/>
				<xsl:variable name="version">
					<xsl:if test="local-name() = 'creatingApplicationVersion'">
						<xsl:apply-templates/>
					</xsl:if>
				</xsl:variable>
				
				<!-- loop over all created elements which come from same tool as version, or are not in conflict -->
				<!-- if there are none, then use the current node from the loop outside this one, so that this loop has at least one iteration -->
				<xsl:for-each select="../fits:created[(@toolname = $version_toolname and @toolversion = $version_toolversion) or $versions_agree or not(@status = 'CONFLICT')] | current()[not(../fits:created[(@toolname = $version_toolname and @toolversion = $version_toolversion) or $versions_agree or not(@status = 'CONFLICT')])]">
					<xsl:variable name="created_toolname" select="@toolname"/>
					<xsl:variable name="created_toolversion" select="@toolversion"/>
					<xsl:variable name="createds_agree" select="not(@status='CONFLICT')"/>
					<xsl:variable name="created">
						<xsl:if test="local-name() = 'created'">
							<xsl:apply-templates/>
						</xsl:if>
					</xsl:variable>
					
					<premis:creatingApplication>
						<!-- check for name of creating application -->
						<xsl:if test="$name != ''">
							<premis:creatingApplicationName>
								<xsl:value-of select="$name"/>
							</premis:creatingApplicationName>
						</xsl:if>
						
						<!-- check for version of creating application -->
						<xsl:if test="$version != ''">
							<premis:creatingApplicationVersion>
								<xsl:value-of select="$version"/>
							</premis:creatingApplicationVersion>
						</xsl:if>
						
						<!-- check for date of creation -->
						<xsl:if test="$created != ''">
							<premis:dateCreatedByApplication>
								<xsl:value-of select="$created"/>
							</premis:dateCreatedByApplication>
						</xsl:if>
						
						<!-- record name and version of tool providing information if there is any conflict -->
						<xsl:if test="not($names_agree and $versions_agree and $createds_agree)">
							<premis:creatingApplicationExtension>
								<fits:tool>
									<xsl:choose>
										<xsl:when test="not($names_agree)">
											<xsl:attribute name="toolname">
												<xsl:value-of select="$name_toolname"/>
											</xsl:attribute>
											<xsl:attribute name="toolversion">
												<xsl:value-of select="$name_toolversion"/>
											</xsl:attribute>
										</xsl:when>
										<xsl:when test="not($versions_agree)">
											<xsl:attribute name="toolname">
												<xsl:value-of select="$version_toolname"/>
											</xsl:attribute>
											<xsl:attribute name="toolversion">
												<xsl:value-of select="$version_toolversion"/>
											</xsl:attribute>
										</xsl:when>
										<xsl:when test="not($createds_agree)">
											<xsl:attribute name="toolname">
												<xsl:value-of select="$createdtoolname"/>
											</xsl:attribute>
											<xsl:attribute name="toolversion">
												<xsl:value-of select="$createdtoolversion"/>
											</xsl:attribute>
										</xsl:when>
									</xsl:choose>
								</fits:tool>
							</premis:creatingApplicationExtension>
						</xsl:if>
					</premis:creatingApplication>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<!-- put FITS metadata into object characteristics extension -->
	<xsl:template match="fits:metadata" mode="object_characteristics_extension">
		<xsl:copy-of select="."/>
	</xsl:template>
	
</xsl:stylesheet>
