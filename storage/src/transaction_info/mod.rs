// Copyright (c) The Starcoin Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::define_storage;
use crate::storage::{CodecKVStore, CodecWriteBatch, ValueCodec};
use crate::TRANSACTION_INFO_HASH_PREFIX_NAME;
use crate::TRANSACTION_INFO_PREFIX_NAME;
use anyhow::{Error, Result};
use bcs_ext::BCSCodec;
use crypto::HashValue;
use starcoin_types::transaction::BlockTransactionInfo;

define_storage!(
    TransactionInfoStorage,
    HashValue,
    BlockTransactionInfo,
    TRANSACTION_INFO_PREFIX_NAME
);

define_storage!(
    TransactionInfoHashStorage,
    HashValue,
    Vec<HashValue>,
    TRANSACTION_INFO_HASH_PREFIX_NAME
);

impl ValueCodec for BlockTransactionInfo {
    fn encode_value(&self) -> Result<Vec<u8>> {
        self.encode()
    }

    fn decode_value(data: &[u8]) -> Result<Self> {
        Self::decode(data)
    }
}

impl TransactionInfoHashStorage {
    pub(crate) fn get_transaction_info_ids_by_hash(
        &self,
        txn_hash: HashValue,
    ) -> Result<Vec<HashValue>, Error> {
        if let Some(txn_id_vec) = self.get(txn_hash)? {
            Ok(txn_id_vec)
        } else {
            Ok(vec![])
        }
    }

    pub(crate) fn save_transaction_infos(
        &self,
        vec_txn_info: Vec<BlockTransactionInfo>,
    ) -> Result<(), Error> {
        let mut batch = CodecWriteBatch::new();
        for txn_info in vec_txn_info {
            if let Ok(Some(mut id_vec)) = self.get(txn_info.transaction_hash()) {
                id_vec.push(txn_info.id());
                batch.put(txn_info.transaction_hash(), id_vec)?;
            } else {
                batch.put(txn_info.transaction_hash(), vec![txn_info.id()])?;
            }
        }
        self.write_batch(batch)
    }
}
impl TransactionInfoStorage {
    pub(crate) fn get_transaction_info(
        &self,
        id: HashValue,
    ) -> Result<Option<BlockTransactionInfo>, Error> {
        self.get(id)
    }
    pub(crate) fn save_transaction_infos(
        &self,
        vec_txn_info: Vec<BlockTransactionInfo>,
    ) -> Result<(), Error> {
        let mut batch = CodecWriteBatch::new();
        for txn_info in vec_txn_info {
            batch.put(txn_info.id(), txn_info)?;
        }
        self.write_batch(batch)
    }
}
// impl BlockTransactionInfoStore for TransactionInfoHashStorage {
//     fn get_transaction_info(&self, _id: HashValue) -> Result<Option<BlockTransactionInfo>, Error> {
//         unreachable!()
//     }
//
//     fn get_transaction_info_by_txn_id(
//         &self,
//         _txn_hash: HashValue,
//     ) -> Result<Vec<BlockTransactionInfo>, Error> {
//         unreachable!()
//     }
//
//     fn get_transaction_info_ids_by_hash(
//         &self,
//         txn_hash: HashValue,
//     ) -> Result<Vec<HashValue>, Error> {
//         if let Some(txn_id_vec) = self.get(txn_hash)? {
//             Ok(txn_id_vec)
//         } else {
//             Ok(vec![])
//         }
//     }
//
//     fn save_transaction_infos(&self, vec_txn_info: Vec<BlockTransactionInfo>) -> Result<(), Error> {
//         let mut batch = CodecWriteBatch::new();
//         for txn_info in vec_txn_info {
//             if let Ok(Some(mut id_vec)) = self.get(txn_info.transaction_hash()) {
//                 id_vec.push(txn_info.id());
//                 batch.put(txn_info.transaction_hash(), id_vec)?;
//             } else {
//                 batch.put(txn_info.transaction_hash(), vec![txn_info.id()])?;
//             }
//         }
//         self.write_batch(batch)
//     }
// }
// impl BlockTransactionInfoStore for TransactionInfoStorage {
//     fn get_transaction_info_by_txn_id(
//         &self,
//         _txn_hash: HashValue,
//     ) -> Result<Vec<BlockTransactionInfo>, Error> {
//         unreachable!()
//     }
//
//     fn get_transaction_info_ids_by_hash(
//         &self,
//         _txn_hash: HashValue,
//     ) -> Result<Vec<HashValue>, Error> {
//         unreachable!()
//     }
//
//     fn save_transaction_infos(&self, vec_txn_info: Vec<BlockTransactionInfo>) -> Result<(), Error> {
//         let mut batch = CodecWriteBatch::new();
//         for txn_info in vec_txn_info {
//             batch.put(txn_info.id(), txn_info)?;
//         }
//         self.write_batch(batch)
//     }
// }
