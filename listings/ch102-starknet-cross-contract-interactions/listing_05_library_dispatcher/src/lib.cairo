#[starknet::interface]
trait IValueStore<TContractState> {
    fn set_value(ref self: TContractState, value: u128);
    fn get_value(self: @TContractState) -> u128;
}

#[starknet::contract]
mod ValueStoreLogic {
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        value: u128,
    }

    #[abi(embed_v0)]
    impl ValueStore of super::IValueStore<ContractState> {
        fn set_value(ref self: ContractState, value: u128) {
            self.value.write(value);
        }

        fn get_value(self: @ContractState) -> u128 {
            self.value.read()
        }
    }
}

#[starknet::contract]
mod ValueStoreExecutor {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ClassHash, ContractAddress};
    use super::{IValueStoreDispatcherTrait, IValueStoreLibraryDispatcher};

    #[storage]
    struct Storage {
        logic_library: ClassHash,
        value: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, logic_library: ClassHash) {
        self.logic_library.write(logic_library);
    }

    #[abi(embed_v0)]
    impl ValueStoreExecutor of super::IValueStore<ContractState> {
        fn set_value(ref self: ContractState, value: u128) {
            IValueStoreLibraryDispatcher { class_hash: self.logic_library.read() }
                .set_value((value));
        }

        fn get_value(self: @ContractState) -> u128 {
            IValueStoreLibraryDispatcher { class_hash: self.logic_library.read() }.get_value()
        }
    }

    #[external(v0)]
    fn get_value_local(self: @ContractState) -> u128 {
        self.value.read()
    }
}
