function [RSK]=rsk2mat_AA(fname)
% Reads a .rsk file and saves it in a mat structure
% Input fname is a string filename without the .rsk extension,
% like 'RBR_filename' for a data file called 'RBR_filename.rsk'

  RSK = RSKopen([fname '.rsk']);
  RSK = RSKreaddata(RSK);
  
  save(fname,'-struct','RSK','-v7.3');
  disp(['Saved .rsk to .mat for ' fname]);
end