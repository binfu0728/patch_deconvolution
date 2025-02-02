% Adapt from MATLAB ginput function. The color can be user defined and the result from each selection is visualized. 
% The selection can be canceled by typing space on the keyboard
function [coord] = ginput(arg1,color)
% input  : arg1, number of centres would be selected from an image
%          color, the color of the cursor, default is white
% output : coord, The coordinate of the selected points (x,y) (i.e, (col, row) for an image)
    xcoord = []; ycoord = [];
    
    % Check Inputs
    if nargin < 2
        color = [1 1 1];
    else
        how_many = arg1;
    end
    
    % Get figure
    fig = gcf;
    drawnow;
    figure(gcf);
    
    % Make sure the figure has an axes
    gca(fig);    
    
    % Setup the figure to disable interactive modes and activate pointers. 
    initialState = setupFcn(fig,color);
    
    % onCleanup object to restore everything to original state in event of
    % completion, closing of figure errors or ctrl+c. 
    c = onCleanup(@() restoreFcn(initialState));
    
    drawnow;

    while how_many ~= 0 && how_many <= arg1
        keydown = wfbp; %0 is mouse click, 1 is keyboard click

        axes_handle = gca;        
        drawnow;
        pt = get(axes_handle, 'CurrentPoint');

        if keydown == 1 %cancel a point selection
            diffx = pt(1,1) - xcoord;
            diffy = pt(1,2) - ycoord;
            idx = find(abs(diffx) < 30 & abs(diffy) < 30);
            if ~isempty(idx)
                xcoord(idx) = [];
                ycoord(idx) = [];
                delete(p)
                delete(t)
                p = plot(xcoord,ycoord,'.','markersize',20);
                t = text(xcoord,ycoord - 30,num2str(arg1 - how_many - 1),'FontSize',15,'Color',color,'FontWeight','bold');
                how_many = how_many + 1;
            end
            continue
        else %select a point                   
            xcoord = [xcoord;pt(1,1)]; %#ok<AGROW>
            ycoord = [ycoord;pt(1,2)]; %#ok<AGROW>
            if how_many < arg1
                delete(p)
                delete(t)
            end
            p = plot(xcoord,ycoord,'.','markersize',20);
            t = text(xcoord,ycoord - 30,num2str(arg1 - how_many + 1),'FontSize',15,'Color',color,'FontWeight','bold');
            how_many = how_many - 1;
        end
    end
    
    % Cleanup and Restore 
    cleanup(c);
    coord = [xcoord,ycoord];
end

function key = wfbp
    %WFBP   Replacement for WAITFORBUTTONPRESS that has no side effects.
    
    fig = gcf;
    current_char = []; %#ok<NASGU>
    
    % Now wait for that buttonpress, and check for error conditions
    waserr = 0;
    try
        h=findall(fig,'Type','uimenu','Accelerator','C');   % Disabling ^C for edit menu so the only ^C is for
        set(h,'Accelerator','');                            % interrupting the function.
        keydown = waitforbuttonpress;
        current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
        if~isempty(current_char) && (keydown == 1)          % If the character was generated by the
            if(current_char == 3)                           % current keypress AND is ^C, set 'waserr'to 1
                waserr = 1;                                 % so that it errors out.
            end
        end
        
        set(h,'Accelerator','C');                           % Set back the accelerator for edit menu.
    catch ME %#ok<NASGU>
        waserr = 1;
    end
    drawnow;
    if(waserr == 1)
        set(h,'Accelerator','C');                          % Set back the accelerator if it errored out.
        error(message('MATLAB:ginput:Interrupted'));
    end
    
    if nargout>0, key = keydown; end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function initialState = setupFcn(fig,color)
    % Store Figure Handle. 
    initialState.figureHandle = fig; 
    
    % Store the PointerMode
    initialState.pointerMode = fig.PointerMode;
    
    % Suspend figure functions
    initialState.uisuspendState = uisuspend(fig);
    
    % Disable Plottools Buttons
    initialState.toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
    if ~isempty(initialState.toolbar)
        initialState.ptButtons = [uigettool(initialState.toolbar,'Plottools.PlottoolsOff'), ...
            uigettool(initialState.toolbar,'Plottools.PlottoolsOn')];
        initialState.ptState = get (initialState.ptButtons,'Enable');
        set (initialState.ptButtons,'Enable','off');
    end
    
    % Disable AxesToolbar
    initialState.axes = findobj(allchild(fig),'-isa','matlab.graphics.axis.AbstractAxes');
    tb = get(initialState.axes, 'Toolbar');
    if ~isempty(tb) && ~iscell(tb)
        initialState.toolbarVisible{1} = tb.Visible;
        tb.Visible = 'off';
    else
        for i=1:numel(tb)
            if ~isempty(tb{i})
                initialState.toolbarVisible{i} = tb{i}.Visible;
                tb{i}.Visible = 'off';
            end
        end
    end
    
    %Setup empty pointer
    cdata = NaN(16,16);
    hotspot = [8,8];
    set(gcf,'Pointer','custom','PointerShapeCData',cdata,'PointerShapeHotSpot',hotspot)
    
    % Create uicontrols to simulate fullcrosshair pointer.
    initialState.CrossHair = createCrossHair(fig,color);
    
    % Adding this to enable automatic updating of currentpoint on the figure 
    % This function is also used to update the display of the fullcrosshair
    % pointer and make them track the currentpoint.
    set(fig,'WindowButtonMotionFcn',@(o,e) dummy()); % Add dummy so that the CurrentPoint is constantly updated
    initialState.MouseListener = addlistener(fig,'WindowMouseMotion', @(o,e) updateCrossHair(o,initialState.CrossHair));
    
    % Get the initial Figure Units
    initialState.fig_units = get(fig,'Units');
end

function restoreFcn(initialState)
    if ishghandle(initialState.figureHandle)
        delete(initialState.CrossHair);    
        
        % Figure Units
        set(initialState.figureHandle,'Units',initialState.fig_units);
        
        set(initialState.figureHandle,'WindowButtonMotionFcn','');
        delete(initialState.MouseListener);
        
        % Plottools Icons
        if ~isempty(initialState.toolbar) && ~isempty(initialState.ptButtons)
            set (initialState.ptButtons(1),'Enable',initialState.ptState{1});
            set (initialState.ptButtons(2),'Enable',initialState.ptState{2});
        end
        
        % Restore axestoolbar
        for i=1:numel(initialState.axes)
            if ~isempty(initialState.axes(i).Toolbar)
                initialState.axes(i).Toolbar.Visible_I = initialState.toolbarVisible{i};
            end
        end    
        
        % UISUSPEND
        uirestore(initialState.uisuspendState);    
        
        % Figure Pointer Mode State
        set(initialState.figureHandle,'PointerMode',initialState.pointerMode);    
    end
end

function updateCrossHair(fig, crossHair)
    % update cross hair for figure.
    gap = 3; % 3 pixel view port between the crosshairs
    cp = hgconvertunits(fig, [fig.CurrentPoint 0 0], fig.Units, 'pixels', fig);
    cp = cp(1:2);
    figPos = hgconvertunits(fig, fig.Position, fig.Units, 'pixels', fig.Parent);
    figWidth = figPos(3);
    figHeight = figPos(4);
    
    % Early return if point is outside the figure
    if cp(1) < gap || cp(2) < gap || cp(1)>figWidth-gap || cp(2)>figHeight-gap
        return
    end
    
    set(crossHair, 'Visible', 'on');
    thickness = 1; % 1 Pixel thin lines. 
    set(crossHair(1), 'Position', [0 cp(2) cp(1)-gap thickness]);
    set(crossHair(2), 'Position', [cp(1)+gap cp(2) figWidth-cp(1)-gap thickness]);
    set(crossHair(3), 'Position', [cp(1) 0 thickness cp(2)-gap]);
    set(crossHair(4), 'Position', [cp(1) cp(2)+gap thickness figHeight-cp(2)-gap]);
end

function crossHair = createCrossHair(fig,color)
    % Create thin uicontrols with black backgrounds to simulate fullcrosshair pointer.
    % 1: horizontal left, 2: horizontal right, 3: vertical bottom, 4: vertical top
    
    if isWebFigureType(fig, 'UIFigure')
        for k = 1:4
            crossHair(k) = uilabel(fig, 'Visible', 'off', 'BackgroundColor', color, 'HandleVisibility', 'off'); %#ok<AGROW>
        end
    else
        for k = 1:4
            crossHair(k) = uicontrol(fig, 'Style', 'text', 'Visible', 'off', 'Units', 'pixels', 'BackgroundColor', color, 'HandleVisibility', 'off', 'HitTest', 'off'); %#ok<AGROW>
        end
    end
end

function cleanup(c)
    if isvalid(c)
        delete(c);
    end
end

function dummy(~,~) 
end