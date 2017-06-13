
function varargout = recoveryGUI(varargin)
% RECOVERYGUI MATLAB code for recoveryGUI.fig
%      RECOVERYGUI, by itself, creates a new RECOVERYGUI or raises the existing
%      singleton*.
%
%      H = RECOVERYGUI returns the handle to a new RECOVERYGUI or the handle to
%      the existing singleton*.
%
%      RECOVERYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECOVERYGUI.M with the given input arguments.
%
%      RECOVERYGUI('Property','Value',...) creates a new RECOVERYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before recoveryGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to recoveryGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recoveryGUI

% Last Modified by GUIDE v2.5 13-Jun-2017 08:45:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recoveryGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @recoveryGUI_OutputFcn, ...
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


% --- Executes just before recoveryGUI is made visible.
function recoveryGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to recoveryGUI (see VARARGIN)

% Choose default command line output for recoveryGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes recoveryGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make objects to use throughout gui
handles.affine = AffineRecovery();
handles.metric = MetricRecovery();
handles.affine.setImage('building.jpg');
handles.metric.setImage('building.jpg');


% configure image display
im = imread('building.jpg');

axes(handles.axesAffine);
axis image
imshow(im);

axes(handles.axesMetric);
axis image
imshow(im);

axes(handles.axesOriginal);
axis image
imshow(im);

% configure dragging of corners

xlim = get(handles.axesOriginal,'XLim');
ylim = get(handles.axesOriginal,'YLim');
initCornerPos = [   xlim(2)/4,ylim(2)/4;...
                    xlim(2)*3/4,ylim(2)/4;...
                    xlim(2)*3/4,ylim(2)*3/4;...
                    xlim(2)/4,ylim(2)*3/4];

for i = 1:4
    
% make custom call for each with an index
cornerFnc = @(pos) newCornerPos(handles,pos,i);
    
cornerHandles = impoint(handles.axesOriginal,initCornerPos(i,:));
handles.affine.setCorner(i,initCornerPos(i,:));
handles.metric.setCorner(i,initCornerPos(i,:));
% link movement of a corner to function
addNewPositionCallback(cornerHandles,cornerFnc);
% Construct boundary constraint function
fcn = makeConstrainToRectFcn('impoint',xlim,ylim);
% Enforce boundary constraint function using setPositionConstraintFcn
setPositionConstraintFcn(cornerHandles,fcn);

end% for

% --- Outputs from this function are returned to the command line.
function varargout = recoveryGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openbutton.
function openbutton_Callback(hObject, eventdata, handles)
% hObject    handle to openbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile({'*.jpg;*.JPEG;*.PNG;*.png'});


% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in closebutton.
function closebutton_Callback(hObject, eventdata, handles)
% hObject    handle to closebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;



function newCornerPos(handles, pos,corner)
    fprintf('Corner %.f moved to [ %.2f, %.2f ]\n',corner,pos(1),pos(2));
    
    handles.affine.setCorner( corner, pos );
    handles.metric.setCorner( corner, pos );
  
