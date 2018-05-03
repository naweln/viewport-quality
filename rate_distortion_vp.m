function rate_distortion_vp(filename, startFolder, panorama, az, el, vp_w, vp_h, fov_v, to_save)

width = vp_w;
height = vp_h;

mkdir(['data/' filename '/vp_w_' num2str(vp_w)]);
cd(['data/' filename '/vp_w_' num2str(vp_w)])
imageFolder = pwd;

for azimuth = az
    for elevation = el
        
        if(abs(elevation) == 90 && azimuth ~= az(1)) continue; end;
        
        mkdir(['az' num2str(azimuth) '_el' num2str(elevation)]);
        
        cd(startFolder)
        original_vp = viewport_extract(panorama, azimuth, elevation, width, height, fov_v);
        original_vp(isnan(original_vp)) = 1;
        if(to_save)
            cd(imageFolder)
            imwrite(original_vp/255, ['az' num2str(azimuth) '_el' num2str(elevation)...
                '/original_vp_az' num2str(azimuth) ...
                '_el' num2str(elevation) '.png']);
        end
        
        variance = var(double(original_vp));
        
        for i = 1:8
            cd(imageFolder)
            quality = 10*i;
            compressed_pano = imread(['../compressed_pano_q' num2str(quality) '.jpg']);
            compressed_pano_info = imfinfo(['../compressed_pano_q' num2str(quality) '.jpg']);
            
            cd(startFolder)
            compressed_vp = viewport_extract(compressed_pano, azimuth, elevation, width, height, fov_v);
            compressed_vp(isnan(compressed_vp)) = 1;
            cd(imageFolder)
            if(to_save)
                imwrite(compressed_vp/255, ['az' num2str(azimuth) '_el' num2str(elevation)...
                    '/compressed_vp_az' num2str(azimuth) ...
                    '_el' num2str(elevation) '_q' num2str(quality) '.png']);
            end
            
            MSE_vp(i) = immse(compressed_vp, original_vp);
            PSNR_vp(i) = psnr(compressed_vp, original_vp, 255); % always write peak value
            SSIM_vp(i) = ssim(compressed_vp, original_vp);
        end
        
        save(['az' num2str(azimuth) '_el' num2str(elevation)...
            '/variance_vp.mat'], 'variance');
        save(['az' num2str(azimuth) '_el' num2str(elevation)...
            '/MSE_vp.mat'], 'MSE_vp');
        save(['az' num2str(azimuth) '_el' num2str(elevation)...
            '/PSNR_vp.mat'], 'PSNR_vp');
        save(['az' num2str(azimuth) '_el' num2str(elevation)...
            '/SSIM_vp.mat'], 'SSIM_vp');
    end
end
