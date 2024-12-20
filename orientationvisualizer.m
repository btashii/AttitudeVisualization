%% Info
% Project: Orientation Visualization using Euler Sequences
% Date: 11/29/2024
% Info: Utilizes a 3-2-1 Euler Sequence to transform an initial position to final position

function gradual_orientation_visualizer_with_model()
clc;
clear all;
close all;

    % Gradual 3D Orientation Visualizer using a custom 3D model (STL file)

    % Specify the local path to the STL file
    stl_file_path = 'model.stl';
    
    % Ensure the file exists
    if ~isfile(stl_file_path)
        error('The specified STL file does not exist: %s', stl_file_path);
    end
    
    % Load the STL file
    model = stlread(stl_file_path);
    scaleFactor = 0.15;

    % Extract model vertices and faces
    vertices = model.Points * scaleFactor;
    faces = model.ConnectivityList;

    % Center the model at the origin for consistent rotation
    vertices = vertices - mean(vertices, 1);

    % Initial orientation (r0) - assume aligned with y-axis
    r0 = [0; 1; 0];

    % Create the figure
    figure('Color', 'k'); % Set figure background to black
    hold on;
    grid on;
    axis equal;
    xlabel('X', 'Color', 'w'); % Set axis labels to white
    ylabel('Y', 'Color', 'w');
    zlabel('Z', 'Color', 'w');
    title('3D Orientation Visualizer with Rotating Frame', 'Color', 'w'); % Set title to white
    view(3); % Set 3D view
    xlim([-2.5, 2.5]);
    ylim([-2.5, 2.5]);
    zlim([-2.5, 2.5]);

    % Set grid and axis properties for a black background
    set(gca, 'Color', 'k', 'GridColor', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');

    % Plot the 3D model
    h_model = patch('Vertices', vertices, 'Faces', faces, ...
                    'FaceColor', [0.8, 0.8, 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    camlight; lighting gouraud;

    % Draw initial orientation vector
    h_r0 = quiver3(0, 0, 0, r0(1), r0(2), r0(3), 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    h_rf = quiver3(0, 0, 0, r0(1), r0(2), r0(3), 0, 'white', 'LineWidth', 2, 'MaxHeadSize', 0.5);

    % Add rotating coordinate frame
    h_x_axis = quiver3(0, 0, 0, 1, 0, 0, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5); % X-axis
    h_y_axis = quiver3(0, 0, 0, 0, 1, 0, 0, 'y', 'LineWidth', 2, 'MaxHeadSize', 0.5); % Y-axis
    h_z_axis = quiver3(0, 0, 0, 0, 0, 1, 0, 'c', 'LineWidth', 2, 'MaxHeadSize', 0.5); % Z-axis
    
    % Add labels for initial and final orientation vectors
    h_r0_label = text(r0(1) * 1.3, r0(2) * 1.3, r0(3) * 1.3, 'r_0', 'Color', 'r', 'FontSize', 10);
    h_rf_label = text(r0(1) * 1.3, r0(2) * 1.3, r0(3) * 1.3, 'r_f', 'Color', 'white', 'FontSize', 10);

    % Add labels for rotating coordinate frame axes
    h_x_axis_label = text(1.5, 0, 0, " X' ", 'Color', 'g', 'FontSize', 10);
    h_y_axis_label = text(0, 1.5, 0, " Y' ", 'Color', 'y', 'FontSize', 10);
    h_z_axis_label = text(0, 0, 1.5, " Z' ", 'Color', 'c', 'FontSize', 10);
    
    % Add a dynamic legend (text box) for vector coordinates, DCM, and angles
    h_legend = annotation('textbox', [0.05, 0.7, 0.3, 0.2], 'Color', 'w', ...
                       'EdgeColor', 'w', 'BackgroundColor', 'k', ...
                       'FontSize', 10, 'FontName', 'Courier', ...
                       'HorizontalAlignment', 'left', 'FitBoxToText','on');

    % Choose mode: manual or automatic
    mode = input('Enter mode ("manual" or "auto"): ', 's');
    if ~ismember(mode, ["manual", "auto"])
        disp('Invalid mode. Exiting.');
        return;
    end

    % Continuously update based on user input or random angles
    while true
        if mode == "manual"
            % Manual mode: Prompt user for roll, pitch, yaw angles
            roll = input('Enter roll (in degrees, or "q" to quit): ', 's');
            if roll == "q"
                break;
            end
            roll = str2double(roll);
            pitch = input('Enter pitch (in degrees): ');
            yaw = input('Enter yaw (in degrees): ');
        else
            % Automatic mode: Generate random angles
            roll = randi([-180, 180]);
            pitch = randi([-90, 90]);
            yaw = randi([-180, 180]);
            pause(0.5); % Pause between updates for visualization
        end

        % Convert angles to radians
        roll = deg2rad(roll);
        pitch = deg2rad(pitch);
        yaw = deg2rad(yaw);

        % Compute Direction Cosine Matrices (DCMs) using Curtis Convention
        % Change of Basis

        DCM_roll = [
            1, 0, 0;
            0, cos(roll), sin(roll);
            0, -sin(roll), cos(roll)
        ];

        DCM_pitch = [
            cos(pitch), 0, -sin(pitch);
            0, 1, 0;
            sin(pitch), 0, cos(pitch)
        ];

        DCM_yaw = [
            cos(yaw), sin(yaw), 0;
            -sin(yaw), cos(yaw), 0;
            0, 0, 1
        ];
        
        % Compute DCMs using Linear Algebra Convention
        %{
        DCM_roll_same = [
            1, 0, 0;
            0, cos(-roll), -sin(-roll);
            0, sin(-roll), cos(-roll)
        ];

        DCM_pitch_same = [
            cos(-pitch), 0, sin(-pitch);
            0, 1, 0;
            -sin(-pitch), 0, cos(-pitch)
        ];

        DCM_yaw_same = [
            cos(-yaw), -sin(-yaw), 0;
            sin(-yaw), cos(-yaw), 0;
            0, 0, 1
        ];
        
        %}

        % Combine DCMs in 3-2-1 Euler Sequence order (yaw, then pitch, then
        % roll)
        DCM_total = DCM_roll * DCM_pitch * DCM_yaw;
        % Compute the new orientation vector with changed basis
        DCM_total = DCM_total.'; 
        rf = DCM_total * r0;
        disp(DCM_total);
        disp("r_f within new frame: " + rf); 
        %DCM_total_same_basis = DCM_roll_same * DCM_pitch_same * DCM_yaw_same; 
        % disp(DCM_total_same_basis * r0);

        % Update the legend with position vector, DCM, and angles
        legend_text = sprintf(['Position Vector (r_f):\n  X: %.2f\n  Y: %.2f\n  Z: %.2f\n\n' ...
                       'DCM (Rotation Matrix):\n  [%.2f, %.2f, %.2f]\n  [%.2f, %.2f, %.2f]\n  [%.2f, %.2f, %.2f]\n\n' ...
                       'Angles (degrees):\n  Roll: %.2f\n  Pitch: %.2f\n  Yaw: %.2f'], ...
                       rf(1), rf(2), rf(3), ...
                       DCM_total(1, 1), DCM_total(1, 2), DCM_total(1, 3), ...
                       DCM_total(2, 1), DCM_total(2, 2), DCM_total(2, 3), ...
                       DCM_total(3, 1), DCM_total(3, 2), DCM_total(3, 3), ...
                       rad2deg(roll), rad2deg(pitch), rad2deg(yaw));

        set(h_legend, 'String', legend_text);

        % Gradual rotation: interpolate between the current and target orientation
        num_steps = 50; % Number of interpolation steps
        for t = linspace(0, 1, num_steps)
            % Interpolate the rotation matrix
            DCM_interpolated = eye(3) * (1 - t) + DCM_total * t; % Weighted interpolation
            DCM_interpolated = orthogonalize(DCM_interpolated); % Ensure orthonormality

            % Rotate the model vertices
            rotated_vertices = (DCM_interpolated * vertices')';

            % Update the model and vectors
            set(h_model, 'Vertices', rotated_vertices);
            set(h_rf, 'UData', rf(1), 'VData', rf(2), 'WData', rf(3));

            % Update rotating coordinate frame
            x_axis = DCM_interpolated * [1; 0; 0];
            y_axis = DCM_interpolated * [0; 1; 0];
            z_axis = aDCM_interpolated * [0; 0; 1];

            set(h_x_axis, 'UData', x_axis(1), 'VData', x_axis(2), 'WData', x_axis(3));
            set(h_y_axis, 'UData', y_axis(1), 'VData', y_axis(2), 'WData', y_axis(3));
            set(h_z_axis, 'UData', z_axis(1), 'VData', z_axis(2), 'WData', z_axis(3));
                
            % Update labels for the final vector
            set(h_rf_label, 'Position', rf' * 1.3);
            
            % Update labels for the rotating coordinate frame
            set(h_x_axis_label, 'Position', x_axis' * 1.1);
            set(h_y_axis_label, 'Position', y_axis' * 1.1);
            set(h_z_axis_label, 'Position', z_axis' * 1.1);

            % Redraw
            drawnow;
        end
    end

    disp('Exiting program.');
end

function DCM_orthogonal = orthogonalize(DCM)
    % Ensure the DCM is orthogonal (orthonormalize via SVD)
    [U, ~, V] = svd(DCM);
    DCM_orthogonal = U * V';
end 
