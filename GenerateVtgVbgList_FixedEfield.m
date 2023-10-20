function [ Vtg_list, Vbg_list ] = GenerateVtgVbgList_FixedEfield(Vtg_min, Vtg_max, Vbg_min, Vbg_max, dtg, dbg, E0, N)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
%   Vbg/dbg-Vtg/dtg = 2*E0

    if (0.5*(Vbg_min/dbg-Vtg_max/dtg) < E0) && (E0 < 0.5*(Vbg_max/dbg-Vtg_min/dtg))
        if Vbg_min/dbg < 2*E0+Vtg_min/dtg
            new_Vtg_1 = Vtg_min;
            new_Vbg_1 = dbg*(2*E0+Vtg_min/dtg);
        else
            new_Vbg_1 = Vbg_min;
            new_Vtg_1 = dtg*(Vbg_min/dbg-2*E0);
        end

        if Vbg_max/dbg > 2*E0+Vtg_max/dtg
            new_Vtg_2 = Vtg_max;
            new_Vbg_2 = dbg*(2*E0+Vtg_max/dtg);
        else
            new_Vbg_2 = Vbg_max;
            new_Vtg_2 = dtg*(Vbg_max/dbg-2*E0);
        end

        Vtg_list = linspace(new_Vtg_1, new_Vtg_2, N);
        Vbg_list = linspace(new_Vbg_1, new_Vbg_2, N);
    else
        Vtg_list = linspace(0, 0, N);
        Vbg_list = linspace(0, 0, N);
    end
end