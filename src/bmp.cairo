#[starknet::interface]
pub trait IBmp<TContractState> {
    fn token_uri(self: @TContractState, token_id: u256) -> ByteArray;
}


#[starknet::contract]
mod Bmp{
    use super::IBmp;
    use bitmap::encoding::{bytes_base64_encode};
    use core::array::ArrayTrait;

    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl BmpImpl of super::IBmp<ContractState> {

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.data_uri(token_id)
        }

    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn data_uri(
            self: @ContractState, token_id: u256
        ) -> ByteArray {
            let image: ByteArray = self.construct_image();

            //let base64_encoded_image: ByteArray = bytes_base64_encode(image);
           // format!("data:image/bmp;base64,{}", base64_encoded_image)
            image
        }


        fn construct_image(
            self: @ContractState,
        ) -> ByteArray {
            let mut bmp = "";
            let width = 100;
            let height = 100;
            let row_padding = ( 4 - (3*width) % 4) % 4; 
            let pixel_data_size = (3 * width * row_padding) * height;
            let file_size:u32 = 54 * pixel_data_size;
            //HEADER, BM
            bmp.append_byte(0x42);
            bmp.append_byte(0x4d);
            //file size
            let file_8:u8 = (file_size & 0xff).try_into().unwrap(); 
            let file_shr_8:u8 = ((file_size / 256) & 0xff).try_into().unwrap();
            let file_shr_16:u8 = ((file_size / 65536) & 0xff).try_into().unwrap();
            let file_shr_24:u8 = ((file_size / 16777216 ) & 0xff).try_into().unwrap();
            bmp.append_byte(file_8);
            bmp.append_byte(file_shr_8);
            bmp.append_byte(file_shr_16);
            bmp.append_byte(file_shr_24);
            // reserved
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            //offset
            bmp.append_byte(54);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);

            //info header
            bmp.append_byte(40);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);

            //image_width
            let width_8 = (width & 0xff).try_into().unwrap();
            bmp.append_byte(width_8);
            let width_shr_8 = ((width / 256) & 0xff).try_into().unwrap();
            bmp.append_byte(width_shr_8); 
            bmp.append_byte(0);
            bmp.append_byte(0);
           
            //image height
            let height_8 = (height & 0xff).try_into().unwrap();
            bmp.append_byte(height_8);
            let height_shr_8 = ((height / 256) & 0xff).try_into().unwrap();
            bmp.append_byte(height_shr_8); 
            bmp.append_byte(0);
            bmp.append_byte(0);
            
            //planes
            bmp.append_byte(1);
            bmp.append_byte(0);

            //bits per pixel
            bmp.append_byte(24);
            bmp.append_byte(0);

            //compression
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);

            //pixel data size
            let pixel_8 = (pixel_data_size & 0xff).try_into().unwrap();
            let pixel_shr_8:u8 = ((pixel_data_size / 256) & 0xff).try_into().unwrap();
            let pixel_shr_16:u8 = ((pixel_data_size / 65536) &0xff).try_into().unwrap();
            bmp.append_byte(pixel_8);
            bmp.append_byte(pixel_shr_8);
            bmp.append_byte(pixel_shr_16);
            bmp.append_byte(0);

            // horizontal res
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            
            //vertical res
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            
            //colors in palette
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            
            //important colors
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);
            bmp.append_byte(0);

            //write pixels
            let mut index = 0;
            while(index < width * height) {
                bmp.append_byte(0);
                bmp.append_byte(0);
                bmp.append_byte(255);
                index += 1;
            };

            return bmp;                        
        }

        fn get_token_name(self: @ContractState, token_id: u256) -> ByteArray {
            return format!("Token #{}", token_id);
        }
}
}
