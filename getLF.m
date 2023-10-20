
function hLF = getLF()
%% initialize LightField
    temp = getappdata(0, 'lfstorage');
    if isempty(temp)
        Setup_LightField_Environment();        
        LF = lfm(true); % open lightfield application and make visible
        setappdata(0, 'lfstorage', LF);
        hLF = getappdata(0, 'lfstorage');
    else
        hLF = temp;
    end
end

%% setappdata(0, 'lfstorage', []);