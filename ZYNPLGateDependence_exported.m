classdef ZYNPLGateDependence_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        LoadEXPEditField                matlab.ui.control.EditField
        LoadEXPEditFieldLabel           matlab.ui.control.Label
        Angle_CrossEditField            matlab.ui.control.NumericEditField
        Angle_CrossEditFieldLabel       matlab.ui.control.Label
        Angle_CoEditField               matlab.ui.control.NumericEditField
        Angle_CoEditFieldLabel          matlab.ui.control.Label
        APT_SNEditField                 matlab.ui.control.NumericEditField
        APT_SNEditFieldLabel            matlab.ui.control.Label
        Switch                          matlab.ui.control.Switch
        SpotLabelEditField              matlab.ui.control.EditField
        SpotLabelEditFieldLabel         matlab.ui.control.Label
        ClearLFStorageButton            matlab.ui.control.Button
        GetLFButton                     matlab.ui.control.Button
        BrowseButton_2                  matlab.ui.control.Button
        BrowseButton                    matlab.ui.control.Button
        StartButton                     matlab.ui.control.Button
        PLordRRButtonGroup              matlab.ui.container.ButtonGroup
        dRRSelectREFFileButton          matlab.ui.control.RadioButton
        PLButton                        matlab.ui.control.RadioButton
        fixedEfieldEditField            matlab.ui.control.NumericEditField
        fixedEfieldEditFieldLabel       matlab.ui.control.Label
        fixeddopingEditField            matlab.ui.control.NumericEditField
        fixeddopingEditFieldLabel       matlab.ui.control.Label
        bBNEditField                    matlab.ui.control.NumericEditField
        bBNEditFieldLabel               matlab.ui.control.Label
        tBNEditField                    matlab.ui.control.NumericEditField
        tBNLabel                        matlab.ui.control.Label
        NEditField                      matlab.ui.control.NumericEditField
        NEditFieldLabel                 matlab.ui.control.Label
        VbgmaxEditField                 matlab.ui.control.NumericEditField
        VbgmaxEditFieldLabel            matlab.ui.control.Label
        VbgminEditField                 matlab.ui.control.NumericEditField
        VbgminEditFieldLabel            matlab.ui.control.Label
        VtgmaxEditField                 matlab.ui.control.NumericEditField
        VtgmaxEditFieldLabel            matlab.ui.control.Label
        VtgminEditField                 matlab.ui.control.NumericEditField
        VtgminEditFieldLabel            matlab.ui.control.Label
        PowerEditField                  matlab.ui.control.NumericEditField
        PowerEditFieldLabel             matlab.ui.control.Label
        CenterWavelengthEditField       matlab.ui.control.NumericEditField
        CenterWavelengthEditFieldLabel  matlab.ui.control.Label
        ExposureTimeEditField           matlab.ui.control.NumericEditField
        ExposureTimeEditFieldLabel      matlab.ui.control.Label
        BackgroundButtonGroup           matlab.ui.container.ButtonGroup
        SelectFileButton                matlab.ui.control.RadioButton
        Button                          matlab.ui.control.RadioButton
        VnmLabel                        matlab.ui.control.Label
        x1012cm2Label                   matlab.ui.control.Label
        nmLabel_4                       matlab.ui.control.Label
        Label_4                         matlab.ui.control.Label
        Label_3                         matlab.ui.control.Label
        Label_2                         matlab.ui.control.Label
        Label                           matlab.ui.control.Label
        nmLabel_3                       matlab.ui.control.Label
        nmLabel_2                       matlab.ui.control.Label
        VLabel_4                        matlab.ui.control.Label
        VLabel_3                        matlab.ui.control.Label
        VLabel_2                        matlab.ui.control.Label
        VLabel                          matlab.ui.control.Label
        uWLabel                         matlab.ui.control.Label
        nmLabel                         matlab.ui.control.Label
        sLabel                          matlab.ui.control.Label
        ModeButtonGroup                 matlab.ui.container.ButtonGroup
        dopingfiniteEfieldButton        matlab.ui.control.RadioButton
        EfieldfinitedopingButton        matlab.ui.control.RadioButton
        bottomgateButton                matlab.ui.control.RadioButton
        topgateButton                   matlab.ui.control.RadioButton
        EfieldButton                    matlab.ui.control.RadioButton
        dopingButton                    matlab.ui.control.RadioButton
        RightPanel                      matlab.ui.container.Panel
        MsgTextArea                     matlab.ui.control.TextArea
        MsgLabel                        matlab.ui.control.Label
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
%             load('LF.mat','lf');
            app.MsgTextArea.Value = 'Initializing LF...';
            lf = getLF();

            lf.load_experiment(app.LoadEXPEditField.Value);
            lf.set_exposure(app.ExposureTimeEditField.Value*1000);
            lf.set_frames(2);
            lf.set(PrincetonInstruments.LightField.AddIns.SpectrometerSettings.GratingCenterWavelength,app.CenterWavelengthEditField.Value);

            if app.Button.Value == true
                BGM = 0;
            elseif app.SelectFileButton.Value == true
                load('BGM.mat','BGM');
            end
            if app.PLButton.Value == true
                REF = 0;
                indexR = 0;
            elseif app.dRRSelectREFFileButton.Value == true
                load('REF.mat','REF');
                indexR = 1;
            end
            
            cmap = cbrewer('div','RdBu',256);
            cmap(cmap<0)=0;
            cmap(cmap>1)=1;
            cmap = flip(cmap);
            datarange = 460:1200;
            exptime = app.ExposureTimeEditField.Value;
            cwl = app.CenterWavelengthEditField.Value;
            ppppower = app.PowerEditField.Value;
            spotnumber = app.SpotLabelEditField.Value;
            Vtg_min = -app.VtgminEditField.Value;
            Vtg_max = app.VtgmaxEditField.Value;
            Vbg_min = -app.VbgminEditField.Value;
            Vbg_max = app.VbgmaxEditField.Value;
            dtg = app.tBNEditField.Value;
            dbg = app.bBNEditField.Value;
            E0 = app.fixedEfieldEditField.Value;
            doping0 = 0.01*app.fixeddopingEditField.Value;
            N = app.NEditField.Value;
            APTSN = app.APT_SNEditField.Value;
            A_co = app.Angle_CoEditField.Value;
            A_cross = app.Angle_CrossEditField.Value;

            app.MsgTextArea.Value = 'Initializing Vtg & Vbg...';
            if app.dopingButton.Value == true
                [ Vtg_list, Vbg_list ] = GenerateVtgVbgList_FixedEfield(Vtg_min, Vtg_max, Vbg_min, Vbg_max, dtg, dbg, 0, N);
                y_D = (Vtg_list/dtg+Vbg_list/dbg).*(3.1*8.854187817*10.0/1.602176487).*0.1;
                y = y_D;
                label_y = 'doping density (10^1^2cm^-^2)';
                title_char = 'D';
                label_title = 'doping dep';
                Vtg_start = Vtg_min;
                Vbg_start = Vbg_min;
                sweepGatesUpdate([Vtg_start Vbg_start],[1 3],[1 3])
                pause(60);
            elseif app.EfieldButton.Value == true
                [ Vtg_list, Vbg_list ] = GenerateVtgVbgList_FixedDoping(Vtg_min, Vtg_max, Vbg_min, Vbg_max, dtg, dbg, 0, N);
                y_E = 0.5*(Vbg_list/dbg-Vtg_list/dtg);
                y = y_E;
                label_y = 'E field (V/nm)';
                title_char = 'E';
                label_title = 'E field dep';
                Vtg_start = 0;
                Vbg_start = 0;
                sweepGatesUpdate([Vtg_start Vbg_start],[1 3],[1 3])
                pause(20);
            elseif app.topgateButton.Value == true
                Vtg_list = linspace(Vtg_min, Vtg_max, N);
                Vbg_list = linspace(0, 0, N);
                y = Vtg_list;
                label_y = 'Vtg (V)';
                title_char = 'TG';
                label_title = 'Vtg dep';
                Vtg_start = Vtg_min;
                Vbg_start = 0;
                sweepGatesUpdate([Vtg_start Vbg_start],[1 3],[1 3])
                pause(60);
            elseif app.bottomgateButton.Value == true
                Vbg_list = linspace(Vbg_min, Vbg_max, N);
                Vtg_list = linspace(0, 0, N);
                y = Vbg_list;
                label_y = 'Vbg (V)';
                title_char = 'BG';
                label_title = 'Vbg dep';
                Vtg_start = 0;
                Vbg_start = Vbg_min;
                sweepGatesUpdate([Vtg_start Vbg_start],[1 3],[1 3])
                pause(60);
            elseif app.EfieldfinitedopingButton.Value == true
                [ Vtg_list, Vbg_list ] = GenerateVtgVbgList_FixedDoping(Vtg_min, Vtg_max, Vbg_min, Vbg_max, dtg, dbg, doping0, N);
                y_E = 0.5*(Vbg_list/dbg-Vtg_list/dtg);
                y = y_E;
                label_y = 'E field (V/nm)';
                title_char = 'FD';
                label_title = ['doping =',32,num2str(100*doping0),'x10^1^2cm^-^2'];
                Vtg_start = 0;
                Vbg_start = 0;
                sweepGatesUpdate([Vtg_start Vbg_start],[1 3],[1 3])
                pause(20);
            elseif app.dopingfiniteEfieldButton.Value == true
                [ Vtg_list, Vbg_list ] = GenerateVtgVbgList_FixedEfield(Vtg_min, Vtg_max, Vbg_min, Vbg_max, dtg, dbg, E0, N);
                y_D = (Vtg_list/dtg+Vbg_list/dbg).*(3.1*8.854187817*10.0/1.602176487).*1.0E-3;
                y = y_D;
                label_y = 'doping density (nm^-^2)';
                title_char = 'FE';
                label_title = ['E =',32,num2str(E0),'V/nm'];
                Vtg_start = Vtg_min;
                Vbg_start = Vbg_min;
                sweepGatesUpdate([Vtg_start Vbg_start],[1 3],[1 3])
                pause(60);
            end
            label_x = 'Energy (eV)';
            app.MsgTextArea.Value = 'Running...';
            y0 = y;
        
            c = clock;
            
            zyntt = [];
            tt0 = c(3)*24*60+c(4)*60+c(5)+c(6)/60;
            
            if string(app.Switch.Value) == "CircularOn"
                xlabel(app.UIAxes,label_x);
                ylabel(app.UIAxes,label_y);
                title(app.UIAxes,[label_title]);
                xlabel(app.UIAxes2,label_x);
                ylabel(app.UIAxes2,label_y);
                title(app.UIAxes2,[label_title]);
                clear APT;
                APT = APT_initialize(APT_SN);
                APT.MoveHome(0,0);
                pause(30);
                PL_mat_co_raw = [];
                PL_mat_co = [];
                PL_mat_cross_raw = [];
                PL_mat_cross = [];
                for i = 1:N
                    Vtg = Vtg_list(i);
                    Vbg = Vbg_list(i);
                    APT.MoveAbsoluteRot(0, A_co, 0, 3, 1);
                    sweepGatesUpdate([Vtg Vbg],[1 3],[1 3])
                    disp('v arrived');
                    try
                        [Ic, x] = lf.acquire();
                    catch
                        app.MsgTextArea.Value = 'LightField not responding attempt recovery.';
                        try
                            clear lf;
                            rmappdata(0,'lfstorage');
                            lf = getLF();
                            pause(120);
                            [Ic, x] = lf.acquire();
                        catch
                            sweepGatesUpdate([0 0],[1 3],[1 3])
                            app.MsgTextArea.Value = 'LightField Crashed, Recovery failed.';
                            error('LightField Crashed, Recovery failed.');
                        end
                    end
                    zyn1 = cmerge_ZYN(Ic(1,:,1),Ic(1,:,2),100);
                    PL_mat_co_raw(i,:) = zyn1;
                    if indexR == 0
                        zyn2 = zyn1-BGM_co;
                        PL_mat_co(i,:) = zyn2;
                    else
                        zyn2 = (zyn1-REF_co)./(REF_co-BGM_co);
                        PL_mat_co(i,:) = zyn2;
                    end
                    APT.MoveAbsoluteRot(0, A_cross, 0, 3, 1);
                    pause(4);
                    try
                        [Ic, x] = lf.acquire();
                    catch
                        app.MsgTextArea.Value = 'LightField not responding attempt recovery.';
                        try
                            clear lf;
                            rmappdata(0,'lfstorage');
                            lf = getLF();
                            pause(120);
                            [Ic, x] = lf.acquire();
                        catch
                            sweepGatesUpdate([0 0],[1 3],[1 3])
                            app.MsgTextArea.Value = 'LightField Crashed, Recovery failed.';
                            error('LightField Crashed, Recovery failed.');
                        end
                    end
                    zyn1 = cmerge_ZYN(Ic(1,:,1),Ic(1,:,2),100);
                    PL_mat_cross_raw(i,:) = zyn1;
                    if indexR == 0
                        zyn2 = zyn1-BGM_cross;
                        PL_mat_cross(i,:) = zyn2;
                    else
                        zyn2 = (zyn1-REF_cross)./(REF_cross-BGM_cross);
                        PL_mat_cross(i,:) = zyn2;
                    end

                    energy = (6.62607004*299.792458/1.602176487)./x;
                    y = y0(1:i);
                    savename1 = ['PL_CirPol_spot',spotnumber,'_SweepDE_',title_char,'_',num2str(ppppower),'uW',num2str(exptime),'sec_mid',num2str(cwl),'_',num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5)),'_',num2str(c(6)),'_ratio_',num2str(10*dtg),'_',num2str(10*dbg)];
                    save([savename1,'.mat'],'x','energy','y','PL_mat_co','PL_mat_co_raw','PL_mat_cross','PL_mat_cross_raw','savename1','label_x','label_y','label_title','Vtg_min','Vbg_min','Vtg_max','Vbg_max','dtg','dbg','BGM_co','REF_co','BGM_cross','REF_cross','indexR');
            
                    if i > 1
                        h1 = pcolor(energy,y(1:i),PL_mat_co,'Parent',app.UIAxes);
                        h1.EdgeColor = 'None';
                        colormap(app.UIAxes,cmap);
                        h2 = pcolor(energy,y(1:i),2*(PL_mat_co-PL_mat_cross)./(PL_mat_co+PL_mat_cross),'Parent',app.UIAxes2);
                        h2.EdgeColor = 'None';
                        colormap(app.UIAxes2,cmap);
                        timer_x = [1:i];
                        c1 = clock;
                        tt1 = c1(3)*24*60+c1(4)*60+c1(5)+c1(6)/60;
                        zyntt(i) = tt1-tt0;
                        P = polyfit(timer_x,zyntt,1);
                        tt_final = polyval(P,N)+tt0;
                        cc1 = floor(tt_final/24/60);
                        cc2 = floor((tt_final-cc1*24*60)/60);
                        cc3 = floor((tt_final-cc1*24*60-cc2*60));
                        cc4 = floor((tt_final-cc1*24*60-cc2*60-cc3)*60);
                        disp([10,num2str(cc1),32,'-',32,num2str(cc2),':',num2str(cc3),':',num2str(cc4),32,'(',num2str(i),32,'of',32,num2str(N),')']);
                        app.MsgTextArea.Value = [num2str(cc1),32,'-',32,num2str(cc2),':',num2str(cc3),':',num2str(cc4),32,'(',num2str(i),32,'of',32,num2str(N),')'];
                    end
                end
                sweepGatesUpdate([0 0],[1 3],[1 3])
                figure;
                h3 = pcolor(energy,y,PL_mat_co);
                h3.EdgeColor = 'None';
                colormap(cmap);
                colorbar;
                xlabel(label_x);
                ylabel(label_y);
                title([label_title]);
                % caxis([-0.25,-0.14])
                saveas(gcf,[savename1,'_co_diff0.bmp'])
                saveas(gcf,[savename1,'_co_diff0.fig'])
                figure;
                h4 = pcolor(energy,y,PL_mat_cross);
                h4.EdgeColor = 'None';
                colormap(cmap);
                colorbar;
                xlabel(label_x);
                ylabel(label_y);
                title([label_title]);
                % caxis([-0.25,-0.14])
                saveas(gcf,[savename1,'_cross_diff0.bmp'])
                saveas(gcf,[savename1,'_cross_diff0.fig'])
                figure;
                h5 = pcolor(energy,y,2*(PL_mat_co-PL_mat_cross)./(PL_mat_co+PL_mat_cross));
                h5.EdgeColor = 'None';
                colormap(cmap);
                colorbar;
                xlabel(label_x);
                ylabel(label_y);
                title([label_title]);
                % caxis([-0.25,-0.14])
                saveas(gcf,[savename1,'_DIFF_diff0.bmp'])
                saveas(gcf,[savename1,'_DIFF_diff0.fig'])
            elseif string(app.Switch.Value) == "CircularOff"
                xlabel(app.UIAxes,label_x);
                ylabel(app.UIAxes,label_y);
                title(app.UIAxes,[label_title]);
                xlabel(app.UIAxes2,'Energy (eV)');
                ylabel(app.UIAxes2,'Counts');
                PL_mat_raw = [];
                PL_mat = [];
                for i = 1:N
                    Vtg = Vtg_list(i);
                    Vbg = Vbg_list(i);
                    
                    sweepGatesUpdate([Vtg Vbg],[1 3],[1 3])
                    disp('v arrived');
    
                    try
                        [Ic, x] = lf.acquire();
                    catch
                        app.MsgTextArea.Value = 'LightField not responding attempt recovery.';
                        try
                            clear lf;
                            rmappdata(0,'lfstorage');
                            lf = getLF();
                            pause(120);
                            [Ic, x] = lf.acquire();
                        catch
                            sweepGatesUpdate([0 0],[1 3],[1 3])
                            app.MsgTextArea.Value = 'LightField Crashed, Recovery failed.';
                            error('LightField Crashed, Recovery failed.');
                        end
                    end
                    zyn1 = cmerge_ZYN(Ic(1,:,1),Ic(1,:,2),100);
                    PL_mat_raw(i,:) = zyn1;
                    if indexR == 0
                        zyn2 = zyn1-BGM;
                        PL_mat(i,:) = zyn2;
                    else
                        zyn2 = (zyn1-REF)./(REF-BGM);
                        PL_mat(i,:) = zyn2;
                    end
            
                    energy = (6.62607004*299.792458/1.602176487)./x;
                    y = y0(1:i);
                    savename1 = ['PL_spot',spotnumber,'_SweepDE_',title_char,'_',num2str(ppppower),'uW',num2str(exptime),'sec_mid',num2str(cwl),'_',num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5)),'_',num2str(c(6)),'_ratio_',num2str(10*dtg),'_',num2str(10*dbg)];
                    save([savename1,'.mat'],'x','energy','y','PL_mat','PL_mat_raw','savename1','label_x','label_y','label_title','Vtg_min','Vbg_min','Vtg_max','Vbg_max','dtg','dbg','BGM','REF','indexR');
            
                    if i > 1
                        h1 = pcolor(energy,y(1:i),PL_mat,'Parent',app.UIAxes);
                        h1.EdgeColor = 'None';
                        colormap(app.UIAxes,cmap);
    %                     colorbar;
                        plot(app.UIAxes2,energy,zyn2)
                        timer_x = [1:i];
                        c1 = clock;
                        tt1 = c1(3)*24*60+c1(4)*60+c1(5)+c1(6)/60;
                        zyntt(i) = tt1-tt0;
                        P = polyfit(timer_x,zyntt,1);
                        tt_final = polyval(P,N)+tt0;
                        cc1 = floor(tt_final/24/60);
                        cc2 = floor((tt_final-cc1*24*60)/60);
                        cc3 = floor((tt_final-cc1*24*60-cc2*60));
                        cc4 = floor((tt_final-cc1*24*60-cc2*60-cc3)*60);
                        disp([10,num2str(cc1),32,'-',32,num2str(cc2),':',num2str(cc3),':',num2str(cc4),32,'(',num2str(i),32,'of',32,num2str(N),')']);
                        app.MsgTextArea.Value = [num2str(cc1),32,'-',32,num2str(cc2),':',num2str(cc3),':',num2str(cc4),32,'(',num2str(i),32,'of',32,num2str(N),')'];
                    end
                end
                sweepGatesUpdate([0 0],[1 3],[1 3])
                figure;
                h = pcolor(energy,y,PL_mat);
                h.EdgeColor = 'None';
                colormap(cmap);
                colorbar;
                xlabel(label_x);
                ylabel(label_y);
                title([label_title]);
                % caxis([-0.25,-0.14])
                saveas(gcf,[savename1,'_diff0.bmp'])
                saveas(gcf,[savename1,'_diff0.fig'])
            end
            app.MsgTextArea.Value = 'Finished.';

        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            if string(app.Switch.Value) == "CircularOn"
                [fname, pname] = uigetfile({'Background_CoPolairzed.csv'});
                if ~ischar(fname)
                    app.MsgTextArea.Value = 'invalid file name.';
                    error('invalid file name.');
                end
                file = importdata([pname, fname]);
                bg10 = file(:,2);
                Nx = length(bg10)/10;
                mat = zeros(10,Nx);
                for i = 1:10
                    mat(i,:) = transpose(bg10(1+(i-1)*Nx:i*Nx));
                end
                BGM_co = ZYNcmerge10(mat,50);
                [fname, pname] = uigetfile({'Background_CrossPolairzed.csv'});
                if ~ischar(fname)
                    app.MsgTextArea.Value = 'invalid file name.';
                    error('invalid file name.');
                end
                file = importdata([pname, fname]);
                bg10 = file(:,2);
                for i = 1:10
                    mat(i,:) = transpose(bg10(1+(i-1)*Nx:i*Nx));
                end
                BGM_cross = ZYNcmerge10(mat,50);
                save('BGM.mat','BGM_co','BGM_cross');
            elseif string(app.Switch.Value) == "CircularOFF"
                [fname, pname] = uigetfile({'*.csv'});
                if ~ischar(fname)
                    app.MsgTextArea.Value = 'invalid file name.';
                    error('invalid file name.');
                end
                file = importdata([pname, fname]);
                bg10 = file(:,2);
                Nx = length(bg10)/10;
                mat = zeros(10,Nx);
                for i = 1:10
                    mat(i,:) = transpose(bg10(1+(i-1)*Nx:i*Nx));
                end
                BGM = ZYNcmerge10(mat,50);
                save('BGM.mat','BGM');
            end
        end

        % Button pushed function: BrowseButton_2
        function BrowseButton_2Pushed(app, event)
            if string(app.Switch.Value) == "CircularOn"
                [fname, pname] = uigetfile({'Reference_CoPolairzed.csv'});
                if ~ischar(fname)
                    app.MsgTextArea.Value = 'invalid file name.';
                    error('invalid file name.');
                end
                file = importdata([pname, fname]);
                ref10 = file(:,2);
                Nx = length(ref10)/10;
                mat = zeros(10,Nx);
                for i = 1:10
                    mat(i,:) = transpose(ref10(1+(i-1)*Nx:i*Nx));
                end
                REF_co = ZYNcmerge10(mat,50);
                [fname, pname] = uigetfile({'Reference_CrossPolairzed.csv'});
                if ~ischar(fname)
                    app.MsgTextArea.Value = 'invalid file name.';
                    error('invalid file name.');
                end
                file = importdata([pname, fname]);
                ref10 = file(:,2);
                for i = 1:10
                    mat(i,:) = transpose(ref10(1+(i-1)*Nx:i*Nx));
                end
                REF_cross = ZYNcmerge10(mat,50);
                save('REF.mat','REF_co','REF_cross');
            elseif string(app.Switch.Value) == "CircularOFF"
                [fname, pname] = uigetfile({'*.csv'});
                if ~ischar(fname)
                    app.MsgTextArea.Value = 'invalid file name.';
                    error('invalid file name.');
                end
                file = importdata([pname, fname]);
                ref10 = file(:,2);
                Nx = length(ref10)/10;
                mat = zeros(10,Nx);
                for i = 1:10
                    mat(i,:) = transpose(ref10(1+(i-1)*Nx:i*Nx));
                end
                REF = ZYNcmerge10(mat,50);
                save('REF.mat','REF');
            end
        end

        % Button pushed function: GetLFButton
        function GetLFButtonPushed(app, event)
            app.MsgTextArea.Value = 'Initializing LF...';
            lf = getLF();
%             pause(120);
%             save('LF.mat','lf');
        end

        % Button pushed function: ClearLFStorageButton
        function ClearLFStorageButtonPushed(app, event)
            clear lf;
            rmappdata(0,'lfstorage');
            app.MsgTextArea.Value = 'LightField Storage Cleared.';
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {797, 797};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {425, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1046 797];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {425, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create ModeButtonGroup
            app.ModeButtonGroup = uibuttongroup(app.LeftPanel);
            app.ModeButtonGroup.Title = 'Mode';
            app.ModeButtonGroup.Position = [26 49 153 170];

            % Create dopingButton
            app.dopingButton = uiradiobutton(app.ModeButtonGroup);
            app.dopingButton.Text = 'doping';
            app.dopingButton.Position = [11 124 58 22];

            % Create EfieldButton
            app.EfieldButton = uiradiobutton(app.ModeButtonGroup);
            app.EfieldButton.Text = 'E field';
            app.EfieldButton.Position = [11 102 65 22];
            app.EfieldButton.Value = true;

            % Create topgateButton
            app.topgateButton = uiradiobutton(app.ModeButtonGroup);
            app.topgateButton.Text = 'top gate';
            app.topgateButton.Position = [11 80 65 22];

            % Create bottomgateButton
            app.bottomgateButton = uiradiobutton(app.ModeButtonGroup);
            app.bottomgateButton.Text = 'bottom gate';
            app.bottomgateButton.Position = [11 58 85 22];

            % Create EfieldfinitedopingButton
            app.EfieldfinitedopingButton = uiradiobutton(app.ModeButtonGroup);
            app.EfieldfinitedopingButton.Text = 'E field @ finite doping';
            app.EfieldfinitedopingButton.Position = [11 35 139 22];

            % Create dopingfiniteEfieldButton
            app.dopingfiniteEfieldButton = uiradiobutton(app.ModeButtonGroup);
            app.dopingfiniteEfieldButton.Text = 'doping @ finite E field';
            app.dopingfiniteEfieldButton.Position = [11 12 139 22];

            % Create sLabel
            app.sLabel = uilabel(app.LeftPanel);
            app.sLabel.Position = [196 683 25 22];
            app.sLabel.Text = 's';

            % Create nmLabel
            app.nmLabel = uilabel(app.LeftPanel);
            app.nmLabel.Position = [196 653 25 22];
            app.nmLabel.Text = 'nm';

            % Create uWLabel
            app.uWLabel = uilabel(app.LeftPanel);
            app.uWLabel.Position = [196 623 25 22];
            app.uWLabel.Text = {'uW'; ''};

            % Create VLabel
            app.VLabel = uilabel(app.LeftPanel);
            app.VLabel.Position = [159 547 25 22];
            app.VLabel.Text = 'V';

            % Create VLabel_2
            app.VLabel_2 = uilabel(app.LeftPanel);
            app.VLabel_2.Position = [159 517 25 22];
            app.VLabel_2.Text = 'V';

            % Create VLabel_3
            app.VLabel_3 = uilabel(app.LeftPanel);
            app.VLabel_3.Position = [159 487 25 22];
            app.VLabel_3.Text = 'V';

            % Create VLabel_4
            app.VLabel_4 = uilabel(app.LeftPanel);
            app.VLabel_4.Position = [159 457 25 22];
            app.VLabel_4.Text = 'V';

            % Create nmLabel_2
            app.nmLabel_2 = uilabel(app.LeftPanel);
            app.nmLabel_2.Position = [316 532 25 22];
            app.nmLabel_2.Text = 'nm';

            % Create nmLabel_3
            app.nmLabel_3 = uilabel(app.LeftPanel);
            app.nmLabel_3.Position = [316 472 25 22];
            app.nmLabel_3.Text = 'nm';

            % Create Label
            app.Label = uilabel(app.LeftPanel);
            app.Label.Position = [82 547 25 22];
            app.Label.Text = '= -';

            % Create Label_2
            app.Label_2 = uilabel(app.LeftPanel);
            app.Label_2.Position = [82 487 25 22];
            app.Label_2.Text = '= -';

            % Create Label_3
            app.Label_3 = uilabel(app.LeftPanel);
            app.Label_3.Position = [82 517 25 22];
            app.Label_3.Text = '=';

            % Create Label_4
            app.Label_4 = uilabel(app.LeftPanel);
            app.Label_4.Position = [82 457 25 22];
            app.Label_4.Text = '=';

            % Create nmLabel_4
            app.nmLabel_4 = uilabel(app.LeftPanel);
            app.nmLabel_4.Position = [294 83 25 22];
            app.nmLabel_4.Text = 'nm';

            % Create x1012cm2Label
            app.x1012cm2Label = uilabel(app.LeftPanel);
            app.x1012cm2Label.Position = [321 83 79 22];
            app.x1012cm2Label.Text = 'x10^12 cm^-2';

            % Create VnmLabel
            app.VnmLabel = uilabel(app.LeftPanel);
            app.VnmLabel.Position = [321 60 34 22];
            app.VnmLabel.Text = 'V/nm';

            % Create BackgroundButtonGroup
            app.BackgroundButtonGroup = uibuttongroup(app.LeftPanel);
            app.BackgroundButtonGroup.Title = 'Background =';
            app.BackgroundButtonGroup.Position = [26 333 153 76];

            % Create Button
            app.Button = uiradiobutton(app.BackgroundButtonGroup);
            app.Button.Text = '0';
            app.Button.Position = [11 30 58 22];
            app.Button.Value = true;

            % Create SelectFileButton
            app.SelectFileButton = uiradiobutton(app.BackgroundButtonGroup);
            app.SelectFileButton.Text = 'Select File';
            app.SelectFileButton.Position = [11 8 78 22];

            % Create ExposureTimeEditFieldLabel
            app.ExposureTimeEditFieldLabel = uilabel(app.LeftPanel);
            app.ExposureTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.ExposureTimeEditFieldLabel.Position = [26 683 82 22];
            app.ExposureTimeEditFieldLabel.Text = {'ExposureTime'; ''};

            % Create ExposureTimeEditField
            app.ExposureTimeEditField = uieditfield(app.LeftPanel, 'numeric');
            app.ExposureTimeEditField.Limits = [0 Inf];
            app.ExposureTimeEditField.Position = [136 683 55 24];
            app.ExposureTimeEditField.Value = 3;

            % Create CenterWavelengthEditFieldLabel
            app.CenterWavelengthEditFieldLabel = uilabel(app.LeftPanel);
            app.CenterWavelengthEditFieldLabel.HorizontalAlignment = 'right';
            app.CenterWavelengthEditFieldLabel.Position = [26 653 104 22];
            app.CenterWavelengthEditFieldLabel.Text = {'CenterWavelength'; ''};

            % Create CenterWavelengthEditField
            app.CenterWavelengthEditField = uieditfield(app.LeftPanel, 'numeric');
            app.CenterWavelengthEditField.Limits = [0 Inf];
            app.CenterWavelengthEditField.Position = [136 653 55 24];
            app.CenterWavelengthEditField.Value = 730;

            % Create PowerEditFieldLabel
            app.PowerEditFieldLabel = uilabel(app.LeftPanel);
            app.PowerEditFieldLabel.HorizontalAlignment = 'right';
            app.PowerEditFieldLabel.Position = [26 623 40 22];
            app.PowerEditFieldLabel.Text = {'Power'; ''};

            % Create PowerEditField
            app.PowerEditField = uieditfield(app.LeftPanel, 'numeric');
            app.PowerEditField.Limits = [0 Inf];
            app.PowerEditField.Position = [136 623 55 24];
            app.PowerEditField.Value = 999;

            % Create VtgminEditFieldLabel
            app.VtgminEditFieldLabel = uilabel(app.LeftPanel);
            app.VtgminEditFieldLabel.HorizontalAlignment = 'right';
            app.VtgminEditFieldLabel.Position = [26 547 46 22];
            app.VtgminEditFieldLabel.Text = {'Vtg min'; ''};

            % Create VtgminEditField
            app.VtgminEditField = uieditfield(app.LeftPanel, 'numeric');
            app.VtgminEditField.Limits = [0 10];
            app.VtgminEditField.Position = [99 547 55 22];
            app.VtgminEditField.Value = 1;

            % Create VtgmaxEditFieldLabel
            app.VtgmaxEditFieldLabel = uilabel(app.LeftPanel);
            app.VtgmaxEditFieldLabel.HorizontalAlignment = 'right';
            app.VtgmaxEditFieldLabel.Position = [26 517 50 22];
            app.VtgmaxEditFieldLabel.Text = {'Vtg max'; ''};

            % Create VtgmaxEditField
            app.VtgmaxEditField = uieditfield(app.LeftPanel, 'numeric');
            app.VtgmaxEditField.Limits = [0 10];
            app.VtgmaxEditField.Position = [99 517 55 22];
            app.VtgmaxEditField.Value = 1;

            % Create VbgminEditFieldLabel
            app.VbgminEditFieldLabel = uilabel(app.LeftPanel);
            app.VbgminEditFieldLabel.HorizontalAlignment = 'right';
            app.VbgminEditFieldLabel.Position = [26 487 50 22];
            app.VbgminEditFieldLabel.Text = {'Vbg min'; ''};

            % Create VbgminEditField
            app.VbgminEditField = uieditfield(app.LeftPanel, 'numeric');
            app.VbgminEditField.Limits = [0 10];
            app.VbgminEditField.Position = [99 487 55 22];
            app.VbgminEditField.Value = 1;

            % Create VbgmaxEditFieldLabel
            app.VbgmaxEditFieldLabel = uilabel(app.LeftPanel);
            app.VbgmaxEditFieldLabel.HorizontalAlignment = 'right';
            app.VbgmaxEditFieldLabel.Position = [26 457 53 22];
            app.VbgmaxEditFieldLabel.Text = {'Vbg max'; ''};

            % Create VbgmaxEditField
            app.VbgmaxEditField = uieditfield(app.LeftPanel, 'numeric');
            app.VbgmaxEditField.Limits = [0 10];
            app.VbgmaxEditField.Position = [99 457 55 22];
            app.VbgmaxEditField.Value = 1;

            % Create NEditFieldLabel
            app.NEditFieldLabel = uilabel(app.LeftPanel);
            app.NEditFieldLabel.HorizontalAlignment = 'right';
            app.NEditFieldLabel.Position = [26 427 25 22];
            app.NEditFieldLabel.Text = {'N ='; ''};

            % Create NEditField
            app.NEditField = uieditfield(app.LeftPanel, 'numeric');
            app.NEditField.Limits = [0 Inf];
            app.NEditField.ValueDisplayFormat = '%.0f';
            app.NEditField.Position = [99 427 55 22];
            app.NEditField.Value = 10;

            % Create tBNLabel
            app.tBNLabel = uilabel(app.LeftPanel);
            app.tBNLabel.HorizontalAlignment = 'right';
            app.tBNLabel.Position = [206 532 36 22];
            app.tBNLabel.Text = {'tBN ='; ''};

            % Create tBNEditField
            app.tBNEditField = uieditfield(app.LeftPanel, 'numeric');
            app.tBNEditField.Limits = [0 Inf];
            app.tBNEditField.Position = [256 532 55 22];
            app.tBNEditField.Value = 20;

            % Create bBNEditFieldLabel
            app.bBNEditFieldLabel = uilabel(app.LeftPanel);
            app.bBNEditFieldLabel.HorizontalAlignment = 'right';
            app.bBNEditFieldLabel.Position = [206 472 39 22];
            app.bBNEditFieldLabel.Text = {'bBN ='; ''};

            % Create bBNEditField
            app.bBNEditField = uieditfield(app.LeftPanel, 'numeric');
            app.bBNEditField.Limits = [0 Inf];
            app.bBNEditField.Position = [256 472 55 22];
            app.bBNEditField.Value = 20;

            % Create fixeddopingEditFieldLabel
            app.fixeddopingEditFieldLabel = uilabel(app.LeftPanel);
            app.fixeddopingEditFieldLabel.HorizontalAlignment = 'right';
            app.fixeddopingEditFieldLabel.Position = [188 83 81 22];
            app.fixeddopingEditFieldLabel.Text = {'fixed doping ='; ''};

            % Create fixeddopingEditField
            app.fixeddopingEditField = uieditfield(app.LeftPanel, 'numeric');
            app.fixeddopingEditField.Limits = [0 Inf];
            app.fixeddopingEditField.Position = [278 83 35 22];
            app.fixeddopingEditField.Value = 0.1;

            % Create fixedEfieldEditFieldLabel
            app.fixedEfieldEditFieldLabel = uilabel(app.LeftPanel);
            app.fixedEfieldEditFieldLabel.HorizontalAlignment = 'right';
            app.fixedEfieldEditFieldLabel.Position = [188 60 78 22];
            app.fixedEfieldEditFieldLabel.Text = {'fixed E field ='; ''};

            % Create fixedEfieldEditField
            app.fixedEfieldEditField = uieditfield(app.LeftPanel, 'numeric');
            app.fixedEfieldEditField.Limits = [0 Inf];
            app.fixedEfieldEditField.Position = [278 60 35 22];
            app.fixedEfieldEditField.Value = 0.1;

            % Create PLordRRButtonGroup
            app.PLordRRButtonGroup = uibuttongroup(app.LeftPanel);
            app.PLordRRButtonGroup.Title = 'PL or dR/R ?';
            app.PLordRRButtonGroup.Position = [26 241 153 76];

            % Create PLButton
            app.PLButton = uiradiobutton(app.PLordRRButtonGroup);
            app.PLButton.Text = 'PL';
            app.PLButton.Position = [11 30 58 22];
            app.PLButton.Value = true;

            % Create dRRSelectREFFileButton
            app.dRRSelectREFFileButton = uiradiobutton(app.PLordRRButtonGroup);
            app.dRRSelectREFFileButton.Text = 'dRR (Select REF File)';
            app.dRRSelectREFFileButton.Position = [11 8 141 22];

            % Create StartButton
            app.StartButton = uibutton(app.LeftPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [157 14 100 22];
            app.StartButton.Text = 'Start';

            % Create BrowseButton
            app.BrowseButton = uibutton(app.LeftPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [196 341 100 22];
            app.BrowseButton.Text = 'Browse';

            % Create BrowseButton_2
            app.BrowseButton_2 = uibutton(app.LeftPanel, 'push');
            app.BrowseButton_2.ButtonPushedFcn = createCallbackFcn(app, @BrowseButton_2Pushed, true);
            app.BrowseButton_2.Position = [196 249 100 22];
            app.BrowseButton_2.Text = 'Browse';

            % Create GetLFButton
            app.GetLFButton = uibutton(app.LeftPanel, 'push');
            app.GetLFButton.ButtonPushedFcn = createCallbackFcn(app, @GetLFButtonPushed, true);
            app.GetLFButton.Position = [95 756 100 22];
            app.GetLFButton.Text = 'Get LF';

            % Create ClearLFStorageButton
            app.ClearLFStorageButton = uibutton(app.LeftPanel, 'push');
            app.ClearLFStorageButton.ButtonPushedFcn = createCallbackFcn(app, @ClearLFStorageButtonPushed, true);
            app.ClearLFStorageButton.Position = [245 745 107 33];
            app.ClearLFStorageButton.Text = 'Clear LF Storage';

            % Create SpotLabelEditFieldLabel
            app.SpotLabelEditFieldLabel = uilabel(app.LeftPanel);
            app.SpotLabelEditFieldLabel.HorizontalAlignment = 'right';
            app.SpotLabelEditFieldLabel.Position = [26 593 60 24];
            app.SpotLabelEditFieldLabel.Text = 'SpotLabel';

            % Create SpotLabelEditField
            app.SpotLabelEditField = uieditfield(app.LeftPanel, 'text');
            app.SpotLabelEditField.Position = [136 593 80 24];
            app.SpotLabelEditField.Value = 'spot1_abc';

            % Create Switch
            app.Switch = uiswitch(app.LeftPanel, 'slider');
            app.Switch.Items = {'CircularOff', 'CircularOn'};
            app.Switch.Position = [306 698 45 20];
            app.Switch.Value = 'CircularOff';

            % Create APT_SNEditFieldLabel
            app.APT_SNEditFieldLabel = uilabel(app.LeftPanel);
            app.APT_SNEditFieldLabel.HorizontalAlignment = 'right';
            app.APT_SNEditFieldLabel.Position = [261 653 56 24];
            app.APT_SNEditFieldLabel.Text = {'APT_SN:'; ''};

            % Create APT_SNEditField
            app.APT_SNEditField = uieditfield(app.LeftPanel, 'numeric');
            app.APT_SNEditField.Limits = [0 Inf];
            app.APT_SNEditField.ValueDisplayFormat = '%.0f';
            app.APT_SNEditField.Position = [326 653 80 24];
            app.APT_SNEditField.Value = 27003873;

            % Create Angle_CoEditFieldLabel
            app.Angle_CoEditFieldLabel = uilabel(app.LeftPanel);
            app.Angle_CoEditFieldLabel.HorizontalAlignment = 'right';
            app.Angle_CoEditFieldLabel.Position = [261 623 69 24];
            app.Angle_CoEditFieldLabel.Text = 'Angle_Co =';

            % Create Angle_CoEditField
            app.Angle_CoEditField = uieditfield(app.LeftPanel, 'numeric');
            app.Angle_CoEditField.Position = [366 623 40 24];

            % Create Angle_CrossEditFieldLabel
            app.Angle_CrossEditFieldLabel = uilabel(app.LeftPanel);
            app.Angle_CrossEditFieldLabel.HorizontalAlignment = 'right';
            app.Angle_CrossEditFieldLabel.Position = [261 593 85 24];
            app.Angle_CrossEditFieldLabel.Text = 'Angle_Cross =';

            % Create Angle_CrossEditField
            app.Angle_CrossEditField = uieditfield(app.LeftPanel, 'numeric');
            app.Angle_CrossEditField.Position = [366 593 40 24];

            % Create LoadEXPEditFieldLabel
            app.LoadEXPEditFieldLabel = uilabel(app.LeftPanel);
            app.LoadEXPEditFieldLabel.HorizontalAlignment = 'right';
            app.LoadEXPEditFieldLabel.Position = [26 713 56 22];
            app.LoadEXPEditFieldLabel.Text = 'LoadEXP';

            % Create LoadEXPEditField
            app.LoadEXPEditField = uieditfield(app.LeftPanel, 'text');
            app.LoadEXPEditField.Position = [91 713 100 22];
            app.LoadEXPEditField.Value = 'Experiment17';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [69 427 483 359];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.RightPanel);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [69 49 483 359];

            % Create MsgLabel
            app.MsgLabel = uilabel(app.RightPanel);
            app.MsgLabel.HorizontalAlignment = 'right';
            app.MsgLabel.Position = [95 14 32 22];
            app.MsgLabel.Text = 'Msg:';

            % Create MsgTextArea
            app.MsgTextArea = uitextarea(app.RightPanel);
            app.MsgTextArea.Position = [142 12 410 26];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ZYNPLGateDependence_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end