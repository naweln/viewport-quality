function rate_distortion_pano(filename, startFolder, panorama, az, el, vp_w, vp_h, fov_v, to_save)
% this function calculates the quality scores for the panorama at the
% viewing directions specified by 'az' and 'el' with viewport
% dimensions 'vp_h' by 'vp_w'.

mkdir(['data/' filename '/saved_pano']);
cd(['data/' filename])
imageFolder = pwd;

imwrite(panorama, 'original_pano.png');
dim = size(panorama);
fov_h = 2*atan(vp_w/vp_h*tan(fov_v/2));

for azimuth = az
    for elevation = el
        
        if(abs(elevation) == 90 && azimuth ~= az(1)), continue; end
        
        clear('MSE_exact', 'MSE_ext', 'PSNR_exact', 'PSNR_ext', 'SSIM_ext');
        mkdir(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)]);
        
        cd(startFolder)
        if(~exist(['data/masks/inside_w' num2str(dim(2)) '_h' num2str(dim(1)) ...
                                   '_az' num2str(az(1)) '_el' num2str(elevation) '.mat' ], 'file'))
            
            [original_portion, inside, wrap_flag] = portion_extract(panorama, az(1), elevation, fov_v, fov_h);
            inside = logical(inside);
            
            save(['data/masks/inside_w' num2str(dim(2)) '_h' num2str(dim(1)) ...
                                  '_az' num2str(az(1)) '_el' num2str(elevation) '.mat' ], 'inside');
            save(['data/masks/wrap_w'   num2str(dim(2)) '_h' num2str(dim(1)) ...
                                  '_az' num2str(az(1)) '_el' num2str(elevation) '.mat' ], 'wrap_flag');
            
            for m = 2:length(az)
                if(abs(elevation)~=90)
                    inside_alt = circshift(inside, round((az(m)-az(1))*dim(2)/360), 2);
                    save(['data/masks/inside_w' num2str(dim(2)) '_h' num2str(dim(1)) ...
                                          '_az' num2str(az(m)) '_el' num2str(elevation) '.mat' ], 'inside_alt');
                    if(~isempty(find(inside_alt(:,1)==1,1)) && ~isempty(find(inside_alt(:,dim(2))==1,1)))
                        wrap_flag_alt = 1;
                    else
                        wrap_flag_alt = 0;
                    end
                    save(['data/masks/wrap_w' num2str(dim(2)) '_h' num2str(dim(1)) ...
                                        '_az' num2str(az(m)) '_el' num2str(elevation) '.mat' ], 'wrap_flag_alt');
                end
            end
        else
            inside =    importdata(['data/masks/inside_w' num2str(dim(2))   '_h' num2str(dim(1)) ...
                                                    '_az' num2str(azimuth) '_el' num2str(elevation) '.mat' ]);
            wrap_flag = importdata(['data/masks/wrap_w'   num2str(dim(2))   '_h' num2str(dim(1)) ...
                                                    '_az' num2str(azimuth) '_el' num2str(elevation) '.mat' ]);
            if(to_save)
                original_portion = 128*ones(dim(1),dim(2));
                for k=1:dim(2)
                    for j=1:dim(1)
                        if(inside(j,k))
                            original_portion(j,k) = panorama(j,k);
                        end
                    end
                end
            end
        end
        
        original_ext = ext_extract(panorama, azimuth, elevation, inside, wrap_flag);
        
        if(to_save)
            cd(imageFolder)
            imwrite(original_portion/255, ['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
                '/original_portion_az' num2str(azimuth) ...
                '_el' num2str(elevation) '.png']);
            imwrite(original_ext, ['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
                '/original_ext_az' num2str(azimuth) ...
                '_el' num2str(elevation) '.png']);
            cd(startFolder)
        end
        
        variance = var(double(panorama(inside)));
        
        for i=1:8
            quality = 10*i;
            cd(imageFolder)
            if((elevation==el(1)) & (azimuth==az(1))) 
                imwrite(panorama, ['compressed_pano_q' num2str(quality) '.jpg'], 'jpg', 'Quality', quality);
            end
            compressed_pano = imread(['compressed_pano_q' num2str(quality) '.jpg']);
            compressed_pano_info = imfinfo(['compressed_pano_q' num2str(quality) '.jpg']);

            cd(startFolder)
            compressed_ext = ext_extract(compressed_pano, azimuth, elevation, inside, wrap_flag);
            
            if(to_save)
            cd(imageFolder)
                compressed_portion = 128*ones(dim(1),dim(2));
                for k=1:dim(2)
                    for j=1:dim(1)
                        if(inside(j,k))
                            compressed_portion(j,k) = compressed_pano(j,k);
                        end
                    end
                end
                imwrite(compressed_portion/255, ['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
                    '/compressed_portion_az' num2str(azimuth) ...
                    '_el' num2str(elevation) '_q' num2str(quality) '.png']);
                imwrite(compressed_ext, ['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
                    '/compressed_ext_az' num2str(azimuth) ...
                    '_el' num2str(elevation) '_q' num2str(quality) '.png']);
            end
            
            
            MSE_exact(i) = immse(compressed_pano(inside), panorama(inside));
            PSNR_exact(i) = psnr(compressed_pano(inside), panorama(inside), 255);
            
            %external rectangle
            MSE_ext(i) = immse(compressed_ext, original_ext);
            PSNR_ext(i) = psnr(compressed_ext, original_ext, 255);
            SSIM_ext(i) = ssim(compressed_ext, original_ext);
            
            bpp_pano(i) = compressed_pano_info.FileSize*8/(dim(1)*dim(2));
        end
        
        cd(imageFolder)
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/variance_pano.mat'], 'variance');
        
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/MSE_exact.mat'], 'MSE_exact');
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/MSE_ext.mat'], 'MSE_ext');
        
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/PSNR_exact.mat'], 'PSNR_exact');
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/PSNR_ext.mat'], 'PSNR_ext');
        
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/SSIM_ext.mat'], 'SSIM_ext');
        
        save(['saved_pano/az' num2str(azimuth) '_el' num2str(elevation)...
            '/bpp_pano.mat'], 'bpp_pano');
        
    end
end