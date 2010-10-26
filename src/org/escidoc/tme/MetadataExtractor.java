package org.escidoc.tme;

import java.io.IOException;

import edu.harvard.hul.ois.fits.exceptions.FitsException;

public interface MetadataExtractor {

	public String extractMetadata(String locator) throws FitsException,
			IOException;

}
