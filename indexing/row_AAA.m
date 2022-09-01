function x = row_AAA(x)
% column_AAA converts data to a row vector
if size(x,1)>1
    x=reshape(x,[1 numel(x)]);
end
end