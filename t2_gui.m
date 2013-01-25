function varargout = t2_gui(varargin)
% T2_GUI MATLAB code for t2_gui.fig
%      T2_GUI, by itself, creates a new T2_GUI or raises the existing
%      singleton*.
%
%      H = T2_GUI returns the handle to a new T2_GUI or the handle to
%      the existing singleton*.
%
%      T2_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T2_GUI.M with the given input arguments.
%
%      T2_GUI('Property','Value',...) creates a new T2_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before t2_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to t2_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help t2_gui

% Last Modified by GUIDE v2.5 18-Jan-2013 10:28:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @t2_gui_OpeningFcn, ...
    'gui_OutputFcn',  @t2_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before t2_gui is made visible.
function t2_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to t2_gui (see VARARGIN)

% Choose default command line output for t2_gui
handles.output = hObject;

% Create structure to hold file list
handles.file_list = {};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes t2_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = t2_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_files.
function add_files_Callback(hObject, eventdata, handles)
% hObject    handle to add_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update handles structure
guidata(hObject, handles);

[filename, pathname, filterindex] = uigetfile( ...
    {  '*.nii','Nifti Files (*.nii)'; ...
	'*2dseq','Bruker Files (2dseq)'; ...
    '*.hdr;*.img','Analyze Files (*.hdr, *.img)';...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on'); %#ok<NASGU>
if isequal(filename,0)
    %disp('User selected Cancel')
else
    %disp(['User selected ', fullfile(pathname, filename)])
    list = get(handles.filename_box,'String');
    
    % Combine path and filename together
    fullpath = strcat(pathname,filename);
    
    % Stupid matlab uses a different datastructure if only one file
    % is selected, handle special case
    if ischar(list)
        list = {list};
    end
    if ischar(filename)
        filename = {filename};
    end
    if ischar(fullpath)
        fullpath = {fullpath};
    end

    filename = filename';
    fullpath = fullpath';
        
    % Add selected files to listbox
	if strcmp(list,'No Files')
		list = filename;
		handles.file_list = fullpath;
	else
		list = [list;  filename];
		handles.file_list = [handles.file_list; fullpath];
	end
    
	% Read and autoset TE if present in description field
	% Use last file on list by default
	[nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(fullpath{end});
	te = nii.hdr.hist.descrip;
	if ~isempty(te)
		set(handles.te_box,'String',te);
	end
	
    set(handles.filename_box,'String',list, 'Value',1)
end
guidata(hObject, handles);



% --- Executes on button press in remove_files.
function remove_files_Callback(hObject, eventdata, handles)
% hObject    handle to remove_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index_selected = get(handles.filename_box,'Value');
list = get(handles.filename_box,'String');
for n=size(index_selected,2):-1:1
    % Remove from end of list first so resizing does not 
    % change subsequent index numbers
    %disp(['User removed ', list{index_selected(n)}]);
    list(index_selected(n)) = [];
    handles.file_list(index_selected(n)) = [];
end

set(handles.filename_box,'String',list, 'Value',1)
guidata(hObject, handles);

% --- Executes on selection change in filename_box.
function filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filename_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filename_box


% --- Executes during object creation, after setting all properties.
function filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function te_box_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to te_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of te_box as text
%        str2double(get(hObject,'String')) returns contents of te_box as a double


% --- Executes during object creation, after setting all properties.
function te_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to te_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('User selected Ok')
file_list = handles.file_list;
te_list = str2num(get(handles.te_box,'String'))'; %#ok<ST2NM>
fit_type = get(get(handles.fittype,'SelectedObject'),'Tag');
number_cpus = str2num(get(handles.number_cpus,'String')); %#ok<ST2NM>
neuroecon = get(handles.neuroecon,'Value');
email = get(handles.email_box,'String');
delete(handles.figure1);
% disp('User selected files: ');
% disp(file_list);
% disp('User slected TE: ');
% disp(te_list);
% disp('User slected fit: ');
% disp(fit_type);
% disp('User slected CPUs: ');
% disp(number_cpus);
% disp('User slected Neuroecon: ');
% disp(neuroecon);
% disp('User slected email: ');
% disp(email);

% Call T2 Function
calculateT2(file_list,te_list,fit_type, number_cpus, neuroecon, email);



% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('User selected Cancel')
delete(handles.figure1);


% --- Executes on button press in neuroecon.
function neuroecon_Callback(hObject, eventdata, handles)
% hObject    handle to neuroecon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neuroecon



function number_cpus_Callback(hObject, eventdata, handles)
% hObject    handle to number_cpus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number_cpus as text
%        str2double(get(hObject,'String')) returns contents of number_cpus as a double


% --- Executes during object creation, after setting all properties.
function number_cpus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to number_cpus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function email_box_Callback(hObject, eventdata, handles)
% hObject    handle to email_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of email_box as text
%        str2double(get(hObject,'String')) returns contents of email_box as a double


% --- Executes during object creation, after setting all properties.
function email_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to email_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end