function [ Vtg_list, Vbg_list ] = GenerateVtgVbgList_FixedDoping(Vtg_min, Vtg_max, Vbg_min, Vbg_max, dtg, dbg, doping0, N)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    AAA = 3.1*8.854187817*10.0/1.602176487.*1.0E-3;
%   Vtg/dtg+Vbg/dbg=doping0/AAA

    if (AAA*(Vtg_min/dtg+Vbg_min/dbg) < doping0) && (doping0 < AAA*(Vtg_max/dtg+Vbg_max/dbg))
        if Vbg_min/dbg < doping0/AAA-Vtg_max/dtg
            new_Vtg_1 = Vtg_max;
            new_Vbg_1 = dbg*(doping0/AAA-Vtg_max/dtg);
        else
            new_Vbg_1 = Vbg_min;
            new_Vtg_1 = dtg*(doping0/AAA-Vbg_min/dbg);
        end

        if Vbg_max/dbg > doping0/AAA-Vtg_min/dtg
            new_Vtg_2 = Vtg_min;
            new_Vbg_2 = dbg*(doping0/AAA-Vtg_min/dtg);
        else
            new_Vbg_2 = Vbg_max;
            new_Vtg_2 = dtg*(doping0/AAA-Vbg_max/dbg);
        end

        Vtg_list = linspace(new_Vtg_1, new_Vtg_2, N);
        Vbg_list = linspace(new_Vbg_1, new_Vbg_2, N);
    else
        Vtg_list = linspace(0, 0, N);
        Vbg_list = linspace(0, 0, N);
    end
end