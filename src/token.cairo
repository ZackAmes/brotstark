#[starknet::interface]
trait IERC721Metadata<TState> {
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
}

#[starknet::interface]
trait IERC721MetadataCamelOnly<TState> {
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
}

#[starknet::interface]
trait IToken <TContractState> {
    fn test(ref self: TContractState) -> ByteArray;
    fn mint(ref self: TContractState);
}

#[starknet::contract]
mod Token {
    
    use super::{IToken, IERC721Metadata, IERC721MetadataCamelOnly};
    use starknet::{get_caller_address, ContractAddress};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use bitmap::bmp::{IBmpDispatcher, IBmpDispatcherTrait};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);


    // ERC721
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    
    #[storage]
    struct Storage {
        bmp: IBmpDispatcher,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    // SRC5
    #[constructor]
    fn constructor(
        ref self: ContractState,
        bmp: ContractAddress
    ) {
        let name = "Bitmap";
        let symbol = "BMP";
        let base_uri ="";
        let bmpDispatcher = IBmpDispatcher {contract_address: bmp};
        self.bmp.write(bmpDispatcher);
        self.erc721.initializer(name, symbol, base_uri);
    }
     #[abi(embed_v0)]
    impl ERC721Metadata of IERC721Metadata<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_name.read()
        }

        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.ERC721_symbol.read()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.bmp.read().token_uri(token_id)
        }
    }


    #[abi(embed_v0)]
    impl ERC721MetadataCamelOnly of IERC721MetadataCamelOnly<ContractState> {
        fn tokenURI(self: @ContractState, tokenId: u256) -> ByteArray {
            self.token_uri(tokenId)
        }
    }
    #[abi(embed_v0)]
    impl TokenImpl of IToken<ContractState> {

        fn mint(ref self: ContractState) {
            self.erc721._mint(get_caller_address(), 1000);
        }

        fn test(ref self: ContractState) -> ByteArray {
            "test"
        }
    }
}
