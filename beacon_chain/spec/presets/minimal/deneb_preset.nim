# beacon_chain
# Copyright (c) 2023-2025 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at https://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at https://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

{.push raises: [], gcsafe.}

# Minimal preset - Deneb
<<<<<<< HEAD
# https://github.com/ethereum/consensus-specs/blob/v1.5.0-beta.5/presets/minimal/deneb.yaml
const
  # `uint64(4096)`
  FIELD_ELEMENTS_PER_BLOB*: uint64 = 4096
  # [customized]
  MAX_BLOB_COMMITMENTS_PER_BLOCK*: uint64 = 32
  # [customized] `floorlog2(get_generalized_index(BeaconBlockBody, 'blob_kzg_commitments')) + 1 + ceillog2(MAX_BLOB_COMMITMENTS_PER_BLOCK)` = 4 + 1 + 5 = 10
  KZG_COMMITMENT_INCLUSION_PROOF_DEPTH* = 10
=======
# https://github.com/ethereum/consensus-specs/blob/v1.6.0-alpha.5/presets/minimal/deneb.yaml
const
  # `uint64(4096)`
  FIELD_ELEMENTS_PER_BLOB*: uint64 = 4096
  # `uint64(4096)`
  MAX_BLOB_COMMITMENTS_PER_BLOCK*: uint64 = 4096
  # `floorlog2(get_generalized_index(BeaconBlockBody, 'blob_kzg_commitments')) + 1 + ceillog2(MAX_BLOB_COMMITMENTS_PER_BLOCK)` = 4 + 1 + 12 = 17
  KZG_COMMITMENT_INCLUSION_PROOF_DEPTH* = 17
>>>>>>> origin/unstable
