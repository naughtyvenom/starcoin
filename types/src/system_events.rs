// Copyright (c) The Starcoin Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::block::{Block, ExecutedBlock};
use crate::sync_status::SyncStatus;
use crate::U256;
use serde::{Deserialize, Serialize};
use starcoin_crypto::HashValue;
use starcoin_vm_types::genesis_config::ConsensusStrategy;
use std::sync::Arc;

#[derive(Clone, Debug)]
pub struct NewHeadBlock(pub Arc<ExecutedBlock>);

/// may be uncle block
#[derive(Clone, Debug)]
pub struct NewBranch(pub Arc<ExecutedBlock>);

#[derive(Clone, Debug)]
pub struct MinedBlock(pub Arc<Block>);

///Fire this event on System start and all service is init.
#[derive(Clone, Debug)]
pub struct SystemStarted;

#[derive(Clone, Debug)]
pub struct SyncStatusChangeEvent(pub SyncStatus);

///Fire this event for generate a new block
#[derive(Clone, Debug)]
pub struct GenerateBlockEvent {
    /// Force break current minting, and Generate new block.
    pub force: bool,
}

impl GenerateBlockEvent {
    pub fn new(force: bool) -> Self {
        Self { force }
    }
}

#[derive(Debug, Clone, Hash, PartialEq, Eq, Serialize, Deserialize)]
pub struct MintBlockEvent {
    pub parent_hash: HashValue,
    pub strategy: ConsensusStrategy,
    #[serde(with = "hex")]
    pub minting_blob: Vec<u8>,
    pub difficulty: U256,
    pub block_number: u64,
}

impl MintBlockEvent {
    pub fn new(
        parent_hash: HashValue,
        strategy: ConsensusStrategy,
        minting_blob: Vec<u8>,
        difficulty: U256,
        block_number: u64,
    ) -> Self {
        Self {
            parent_hash,
            strategy,
            minting_blob,
            difficulty,
            block_number,
        }
    }
}
