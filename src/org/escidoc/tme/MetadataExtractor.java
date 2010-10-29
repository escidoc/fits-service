package org.escidoc.tme;

import java.io.IOException;

import org.escidoc.tme.exceptions.MetadataExtractorException;

public interface MetadataExtractor {

    /**
     * Extracts technical metadata from file specified by locator. Which kinds
     * of locator are accepted depends on the concrete MetadataExtractor.
     * 
     * @param locator
     *            The location of the file to extract technical metadata from.
     * @return A string containing an XML document. TODO better return XML
     *         document because of charset?
     * @throws MetadataExtractorException
     *             If an error occurs extracting metadata.
     * @throws IOException
     *             If the file can not be read.
     */
    public String extractMetadata(String locator) throws MetadataExtractorException,
        IOException;

}
