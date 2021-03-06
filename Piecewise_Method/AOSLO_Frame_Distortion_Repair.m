% AOSLO_Frame_Distortion_Repair
%
% This script removes residual distortion from both the vertical and horizontal
% (slow and fast scanners in this case, respectively) from a DeMotion strip-registered dataset.
%
% It requires the user to select the desinusoid file for the dataset of interest, then select the folder
% containing all of the images AND the [imagename]_transform.csv files that the user wishes to repair.
%
%
% Copyright (C) 2018 Robert Cooper
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

clear;
close all;
clc

% Check this version of EMR against git.
fid = fopen(fullfile(getparent(which(mfilename)),'.VERSION'),'r');
if fid ~= -1
    thisver = fscanf(fid,'%s');
    fclose(fid);
    
    git_version_check( 'Eurybiadan','Eye-Motion-Repair', thisver )
else
    warning('Failed to detect .VERSION file, unable to determine if running the newest version.')
end

answer = questdlg('Correct residual static vertical distortions? (Dubra Software Only)');
switch answer
    case 'Yes'
        [distortfile, distortpath]=uigetfile('*.mat','Select the desinusoid file for this dataset.');
        static_vert_grid_distortion = Static_Distortion_Repair(fullfile(distortpath,distortfile));
    case 'No'
        static_vert_grid_distortion=[];
    case 'Cancel'
        return;
end
motion_path = uigetdir(pwd,'Select folder of images/videos you wish to remove distortion from:');

fNames = read_folder_contents(motion_path,'tif');

if exist('parfor','builtin') == 5 % If we can multithread it, do it!
    parfor i=1:length(fNames)
        Eye_Motion_Distortion_Repair(motion_path, fNames{i}, static_vert_grid_distortion);
    end

else
    for i=1:length(fNames)
        Eye_Motion_Distortion_Repair(motion_path, fNames{i}, static_vert_grid_distortion);
    end
end