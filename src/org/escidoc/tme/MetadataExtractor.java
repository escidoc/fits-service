package org.escidoc.tme;

import java.io.File;

import edu.harvard.hul.ois.fits.exceptions.FitsException;

public interface MetadataExtractor {
	
	public String extractMetadata(File f) throws FitsException;

}
