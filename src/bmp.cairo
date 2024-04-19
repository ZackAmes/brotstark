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

            let base64_encoded_image: ByteArray = bytes_base64_encode(image);
            format!("data:image/bmp;base64,{}", base64_encoded_image)
        }


        fn construct_image(
            self: @ContractState,
        ) -> ByteArray {
            // construct svg image
            let bmp = "test";
            return bmp;                        
        }

        fn get_token_name(self: @ContractState, token_id: u256) -> ByteArray {
            return format!("Token #{}", token_id);
        }
}
}
