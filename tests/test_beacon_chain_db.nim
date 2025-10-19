# beacon_chain
# Copyright (c) 2018-2025 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or https://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or https://opensource.org/licenses/MIT)
# at your option. This file may not be copied, modified, or distributed except according to those terms.

{.push raises: [].}
{.used.}

import
  unittest2,
  ../beacon_chain/[beacon_chain_db, beacon_chain_db_quarantine],
  ../beacon_chain/consensus_object_pools/block_dag,
  ../beacon_chain/spec/forks,
  ./testutil

from std/algorithm import sort
from std/sequtils import allIt, toSeq
from snappy import encodeFramed, uncompressedLenFramed
from ../beacon_chain/consensus_object_pools/block_pools_types import
  ChainDAGRef
from ../beacon_chain/consensus_object_pools/blockchain_dag import init
from ../beacon_chain/spec/beaconstate import
  initialize_hashed_beacon_state_from_eth1
from ../beacon_chain/spec/state_transition import noRollback
from ../beacon_chain/validators/validator_monitor import ValidatorMonitor
from ./consensus_spec/fixtures_utils import genesisTestruntimeConfig
from ./mocking/mock_genesis import mockEth1BlockHash
from ./testblockutil import makeInitialDeposits
from ./testdbutil import makeTestDB
from ./teststateutil import getTestStates

when isMainModule:
  import chronicles # or some random compile error happens...

template BeaconStateRef(kind: static ConsensusFork): typedesc =
  when kind == ConsensusFork.Gloas:
    gloas.BeaconStateRef
  elif kind == ConsensusFork.Fulu:
    fulu.BeaconStateRef
  elif kind == ConsensusFork.Electra:
    electra.BeaconStateRef
  elif kind == ConsensusFork.Deneb:
    deneb.BeaconStateRef
  elif kind == ConsensusFork.Capella:
    capella.BeaconStateRef
  elif kind == ConsensusFork.Bellatrix:
    bellatrix.BeaconStateRef
  elif kind == ConsensusFork.Altair:
    altair.BeaconStateRef
  elif kind == ConsensusFork.Phase0:
    phase0.BeaconStateRef
  else:
    {.error: "BeaconStateRef unsupported in " & $kind.}

template NilableBeaconStateRef(kind: static ConsensusFork): typedesc =
  when kind == ConsensusFork.Gloas:
    gloas.NilableBeaconStateRef
  elif kind == ConsensusFork.Fulu:
    fulu.NilableBeaconStateRef
  elif kind == ConsensusFork.Electra:
    electra.NilableBeaconStateRef
  elif kind == ConsensusFork.Deneb:
    deneb.NilableBeaconStateRef
  elif kind == ConsensusFork.Capella:
    capella.NilableBeaconStateRef
  elif kind == ConsensusFork.Bellatrix:
    bellatrix.NilableBeaconStateRef
  elif kind == ConsensusFork.Altair:
    altair.NilableBeaconStateRef
  elif kind == ConsensusFork.Phase0:
    phase0.NilableBeaconStateRef
  else:
    {.error: "NilableBeaconStateRef unsupported in " & $kind.}

template TrustedBeaconBlock(kind: static ConsensusFork): typedesc =
  when kind == ConsensusFork.Gloas:
    gloas.TrustedBeaconBlock
  elif kind == ConsensusFork.Fulu:
    fulu.TrustedBeaconBlock
  elif kind == ConsensusFork.Electra:
    electra.TrustedBeaconBlock
  elif kind == ConsensusFork.Deneb:
    deneb.TrustedBeaconBlock
  elif kind == ConsensusFork.Capella:
    capella.TrustedBeaconBlock
  elif kind == ConsensusFork.Bellatrix:
    bellatrix.TrustedBeaconBlock
  elif kind == ConsensusFork.Altair:
    altair.TrustedBeaconBlock
  elif kind == ConsensusFork.Phase0:
    phase0.TrustedBeaconBlock
  else:
    {.error: "TrustedBeaconBlock unsupported in " & $kind.}

proc getStateRef(
    db: BeaconChainDB,
    consensusFork: static ConsensusFork,
    root: Eth2Digest): auto =
  # load beaconstate the way the block pool does it - into an existing instance
  var res: consensusFork.NilableBeaconStateRef =
    (consensusFork.BeaconStateRef)()
  if not db.getState(root, res[], noRollback):
    res = nil
  res

<<<<<<< HEAD
proc getAltairStateRef(db: BeaconChainDB, root: Eth2Digest):
    altair.NilableBeaconStateRef =
  # load beaconstate the way the block pool does it - into an existing instance
  let res = (altair.BeaconStateRef)()
  if db.getState(root, res[], noRollback):
    return res

proc getBellatrixStateRef(db: BeaconChainDB, root: Eth2Digest):
    bellatrix.NilableBeaconStateRef =
  # load beaconstate the way the block pool does it - into an existing instance
  let res = (bellatrix.BeaconStateRef)()
  if db.getState(root, res[], noRollback):
    return res

proc getCapellaStateRef(db: BeaconChainDB, root: Eth2Digest):
    capella.NilableBeaconStateRef =
  # load beaconstate the way the block pool does it - into an existing instance
  let res = (capella.BeaconStateRef)()
  if db.getState(root, res[], noRollback):
    return res

proc getDenebStateRef(db: BeaconChainDB, root: Eth2Digest):
    deneb.NilableBeaconStateRef =
  # load beaconstate the way the block pool does it - into an existing instance
  let res = (deneb.BeaconStateRef)()
  if db.getState(root, res[], noRollback):
    return res

proc getElectraStateRef(db: BeaconChainDB, root: Eth2Digest):
    electra.NilableBeaconStateRef =
  # load beaconstate the way the block pool does it - into an existing instance
  let res = (electra.BeaconStateRef)()
  if db.getState(root, res[], noRollback):
    return res

proc getFuluStateRef(db: BeaconChainDB, root: Eth2Digest):
    fulu.NilableBeaconStateRef =
  # load beaconstate the way the block pool does it - into an existence instance
  let res = (fulu.BeaconStateRef)()
  if db.getState(root, res[], noRollback):
    return res

func withDigest(blck: phase0.TrustedBeaconBlock):
    phase0.TrustedSignedBeaconBlock =
  phase0.TrustedSignedBeaconBlock(
=======
func withDigest(blck: ForkyTrustedBeaconBlock): auto =
  typeof(blck).kind.TrustedSignedBeaconBlock(
>>>>>>> origin/unstable
    message: blck,
    root: hash_tree_root(blck))

<<<<<<< HEAD
func withDigest(blck: altair.TrustedBeaconBlock):
    altair.TrustedSignedBeaconBlock =
  altair.TrustedSignedBeaconBlock(
    message: blck,
    root: hash_tree_root(blck)
  )

func withDigest(blck: bellatrix.TrustedBeaconBlock):
    bellatrix.TrustedSignedBeaconBlock =
  bellatrix.TrustedSignedBeaconBlock(
    message: blck,
    root: hash_tree_root(blck)
  )

func withDigest(blck: capella.TrustedBeaconBlock):
    capella.TrustedSignedBeaconBlock =
  capella.TrustedSignedBeaconBlock(
    message: blck,
    root: hash_tree_root(blck)
  )

func withDigest(blck: deneb.TrustedBeaconBlock):
    deneb.TrustedSignedBeaconBlock =
  deneb.TrustedSignedBeaconBlock(
    message: blck,
    root: hash_tree_root(blck)
  )

func withDigest(blck: electra.TrustedBeaconBlock):
    electra.TrustedSignedBeaconBlock =
  electra.TrustedSignedBeaconBlock(
    message: blck,
    root: hash_tree_root(blck)
  )

func withDigest(blck: fulu.TrustedBeaconBlock):
    fulu.TrustedSignedBeaconBlock =
  fulu.TrustedSignedBeaconBlock(
    message: blck,
    root: hash_tree_root(blck)
  )

proc getTestStates(consensusFork: ConsensusFork): auto =
=======
proc getTestStates(
    cfg: RuntimeConfig,
    consensusFork: ConsensusFork): seq[ref ForkedHashedBeaconState] =
>>>>>>> origin/unstable
  let
    db = cfg.makeTestDB(SLOTS_PER_EPOCH)
    validatorMonitor = newClone(ValidatorMonitor.init(cfg.time))
    dag = init(ChainDAGRef, cfg, db, validatorMonitor, {})
  var testStates = getTestStates(dag.headState, consensusFork)

  # Ensure transitions beyond just adding validators and increasing slots
  sort(testStates) do (x, y: ref ForkedHashedBeaconState) -> int:
    cmp($getStateRoot(x[]), $getStateRoot(y[]))

  testStates

# Each set of states gets used twice, so scope them to module
let
<<<<<<< HEAD
  testStatesPhase0    = getTestStates(ConsensusFork.Phase0)
  testStatesAltair    = getTestStates(ConsensusFork.Altair)
  testStatesBellatrix = getTestStates(ConsensusFork.Bellatrix)
  testStatesCapella   = getTestStates(ConsensusFork.Capella)
  testStatesDeneb     = getTestStates(ConsensusFork.Deneb)
  testStatesElectra   = getTestStates(ConsensusFork.Electra)
  testStatesFulu      = getTestStates(ConsensusFork.Fulu)

doAssert len(testStatesPhase0) > 8
doAssert len(testStatesAltair) > 8
doAssert len(testStatesBellatrix) > 8
doAssert len(testStatesCapella) > 8
doAssert len(testStatesDeneb) > 8
doAssert len(testStatesElectra) > 8
doAssert len(testStatesFulu) > 8
=======
  cfg = defaultRuntimeConfig
  testStates = block:
    var res: array[ConsensusFork, seq[ref ForkedHashedBeaconState]]
    for consensusFork in ConsensusFork:
      res[consensusFork] = cfg.getTestStates(consensusFork)
    res
doAssert testStates.allIt(it.len > 8)
>>>>>>> origin/unstable

suite "Beacon chain DB" & preset():
  test "empty database" & preset():
    var db = BeaconChainDB.new("", cfg, inMemory = true)
    check:
      db.getStateRef(ConsensusFork.Phase0, ZERO_HASH).isNil
      db.getBlock(ZERO_HASH, phase0.TrustedSignedBeaconBlock).isNone

  template doBlockTest(consensusFork: static ConsensusFork): untyped =
    block:
      let db = BeaconChainDB.new(
        "", consensusFork.genesisTestRuntimeConfig, inMemory = true)

      let
        signedBlock = withDigest((consensusFork.TrustedBeaconBlock)())
        root = hash_tree_root(signedBlock.message)

      db.putBlock(signedBlock)

      var tmp, tmp2: seq[byte]
      check db.containsBlock(root)
      const fork = consensusFork
      withAll(ConsensusFork):
        let ok = db.containsBlock(root, consensusFork.TrustedSignedBeaconBlock)
        check ok == (consensusFork == fork)
      check:
        db.getBlock(
          root, consensusFork.TrustedSignedBeaconBlock).get() == signedBlock
        db.getBlockSSZ(root, tmp, consensusFork.TrustedSignedBeaconBlock)
        db.getBlockSZ(root, tmp2, consensusFork.TrustedSignedBeaconBlock)
        tmp == SSZ.encode(signedBlock)
        tmp2 == encodeFramed(tmp)
        uncompressedLenFramed(tmp2).isSome

<<<<<<< HEAD
    check:
      db.delBlock(ConsensusFork.Phase0, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, phase0.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, phase0.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, phase0.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check Altair blocks" & preset():
    let db = BeaconChainDB.new("", inMemory = true)

    let
      signedBlock = withDigest((altair.TrustedBeaconBlock)())
      root = hash_tree_root(signedBlock.message)

    db.putBlock(signedBlock)

    var tmp, tmp2: seq[byte]
    check:
      db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, altair.TrustedSignedBeaconBlock).get() == signedBlock
      db.getBlockSSZ(root, tmp, altair.TrustedSignedBeaconBlock)
      db.getBlockSZ(root, tmp2, altair.TrustedSignedBeaconBlock)
      tmp == SSZ.encode(signedBlock)
      tmp2 == encodeFramed(tmp)
      uncompressedLenFramed(tmp2).isSome

    check:
      db.delBlock(ConsensusFork.Altair, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, altair.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, altair.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, altair.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check Bellatrix blocks" & preset():
    let db = BeaconChainDB.new("", inMemory = true)

    let
      signedBlock = withDigest((bellatrix.TrustedBeaconBlock)())
      root = hash_tree_root(signedBlock.message)

    db.putBlock(signedBlock)

    var tmp, tmp2: seq[byte]
    check:
      db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, bellatrix.TrustedSignedBeaconBlock).get() == signedBlock
      db.getBlockSSZ(root, tmp, bellatrix.TrustedSignedBeaconBlock)
      db.getBlockSZ(root, tmp2, bellatrix.TrustedSignedBeaconBlock)
      tmp == SSZ.encode(signedBlock)
      tmp2 == encodeFramed(tmp)
      uncompressedLenFramed(tmp2).isSome

    check:
      db.delBlock(ConsensusFork.Bellatrix, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, bellatrix.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, bellatrix.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, bellatrix.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check Capella blocks" & preset():
    let db = BeaconChainDB.new("", inMemory = true)

    let
      signedBlock = withDigest((capella.TrustedBeaconBlock)())
      root = hash_tree_root(signedBlock.message)

    db.putBlock(signedBlock)

    var tmp, tmp2: seq[byte]
    check:
      db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      db.getBlock(root, capella.TrustedSignedBeaconBlock).get() == signedBlock
      db.getBlockSSZ(root, tmp, capella.TrustedSignedBeaconBlock)
      db.getBlockSZ(root, tmp2, capella.TrustedSignedBeaconBlock)
      tmp == SSZ.encode(signedBlock)
      tmp2 == encodeFramed(tmp)
      uncompressedLenFramed(tmp2).isSome

    check:
      db.delBlock(ConsensusFork.Capella, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, capella.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, capella.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, capella.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check Deneb blocks" & preset():
    let db = BeaconChainDB.new("", inMemory = true)

    let
      signedBlock = withDigest((deneb.TrustedBeaconBlock)())
      root = hash_tree_root(signedBlock.message)

    db.putBlock(signedBlock)

    var tmp, tmp2: seq[byte]
    check:
      db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, deneb.TrustedSignedBeaconBlock).get() == signedBlock
      db.getBlockSSZ(root, tmp, deneb.TrustedSignedBeaconBlock)
      db.getBlockSZ(root, tmp2, deneb.TrustedSignedBeaconBlock)
      tmp == SSZ.encode(signedBlock)
      tmp2 == encodeFramed(tmp)
      uncompressedLenFramed(tmp2).isSome

    check:
      db.delBlock(ConsensusFork.Deneb, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      db.getBlock(root, deneb.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, deneb.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, deneb.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check Electra blocks" & preset():
    let db = BeaconChainDB.new("", inMemory = true)

    let
      signedBlock = withDigest((electra.TrustedBeaconBlock)())
      root = hash_tree_root(signedBlock.message)

    db.putBlock(signedBlock)

    var tmp, tmp2: seq[byte]
    check:
      db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      db.getBlock(root, electra.TrustedSignedBeaconBlock).get() == signedBlock
      db.getBlockSSZ(root, tmp, electra.TrustedSignedBeaconBlock)
      db.getBlockSZ(root, tmp2, electra.TrustedSignedBeaconBlock)
      tmp == SSZ.encode(signedBlock)
      tmp2 == encodeFramed(tmp)
      uncompressedLenFramed(tmp2).isSome

    check:
      db.delBlock(ConsensusFork.Electra, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      db.getBlock(root, electra.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, electra.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, electra.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check Fulu blocks" & preset():
    let db = BeaconChainDB.new("", inMemory = true)

    let
      signedBlock = withDigest((fulu.TrustedBeaconBlock)())
      root = hash_tree_root(signedBlock.message)

    db.putBlock(signedBlock)

    var tmp, tmp2: seq[byte]
    check:
      db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, fulu.TrustedSignedBeaconBlock).get() == signedBlock
      db.getBlockSSZ(root, tmp, fulu.TrustedSignedBeaconBlock)
      db.getBlockSZ(root, tmp2, fulu.TrustedSignedBeaconBlock)
      tmp == SSZ.encode(signedBlock)
      tmp2 == encodeFramed(tmp)
      uncompressedLenFramed(tmp2).isSome

    check:
      db.delBlock(ConsensusFork.Fulu, root)
      not db.containsBlock(root)
      not db.containsBlock(root, phase0.TrustedSignedBeaconBlock)
      not db.containsBlock(root, altair.TrustedSignedBeaconBlock)
      not db.containsBlock(root, bellatrix.TrustedSignedBeaconBlock)
      not db.containsBlock(root, capella.TrustedSignedBeaconBlock)
      not db.containsBlock(root, deneb.TrustedSignedBeaconBlock)
      not db.containsBlock(root, electra.TrustedSignedBeaconBlock)
      not db.containsBlock(root, fulu.TrustedSignedBeaconBlock)
      db.getBlock(root, fulu.TrustedSignedBeaconBlock).isErr()
      not db.getBlockSSZ(root, tmp, fulu.TrustedSignedBeaconBlock)
      not db.getBlockSZ(root, tmp2, fulu.TrustedSignedBeaconBlock)

    db.putStateRoot(root, signedBlock.message.slot, root)
    var root2 = root
    root2.data[0] = root.data[0] + 1
    db.putStateRoot(root, signedBlock.message.slot + 1, root2)

    check:
      db.getStateRoot(root, signedBlock.message.slot).get() == root
      db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

    db.close()

  test "sanity check phase 0 states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesPhase0:
      let root = state[].phase0Data.root
      db.putState(root, state[].phase0Data.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getPhase0StateRef(root)[]) == root

      db.delState(ConsensusFork.Phase0, root)
      check:
        not db.containsState(root)
        db.getPhase0StateRef(root).isNil

    db.close()

  test "sanity check Altair states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesAltair:
      let root = state[].altairData.root
      db.putState(root, state[].altairData.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getAltairStateRef(root)[]) == root

      db.delState(ConsensusFork.Altair, root)
      check:
        not db.containsState(root)
        db.getAltairStateRef(root).isNil

    db.close()

  test "sanity check Bellatrix states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesBellatrix:
      let root = state[].bellatrixData.root
      db.putState(root, state[].bellatrixData.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getBellatrixStateRef(root)[]) == root

      db.delState(ConsensusFork.Bellatrix, root)
      check:
        not db.containsState(root)
        db.getBellatrixStateRef(root).isNil

    db.close()

  test "sanity check Capella states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesCapella:
      let root = state[].capellaData.root
      db.putState(root, state[].capellaData.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getCapellaStateRef(root)[]) == root

      db.delState(ConsensusFork.Capella, root)
      check:
        not db.containsState(root)
        db.getCapellaStateRef(root).isNil

    db.close()

  test "sanity check Deneb states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesDeneb:
      let root = state[].denebData.root
      db.putState(root, state[].denebData.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getDenebStateRef(root)[]) == root

      db.delState(ConsensusFork.Deneb, root)
      check:
        not db.containsState(root)
        db.getDenebStateRef(root).isNil

    db.close()

  test "sanity check Electra states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesElectra:
      let root = state[].electraData.root
      db.putState(root, state[].electraData.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getElectraStateRef(root)[]) == root

      db.delState(ConsensusFork.Electra, root)
      check:
        not db.containsState(root)
        db.getElectraStateRef(root).isNil

    db.close()

  test "sanity check Fulu states" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)

    for state in testStatesFulu:
      let root = state[].fuluData.root
      db.putState(root, state[].fuluData.data)

      check:
        db.containsState(root)
        hash_tree_root(db.getFuluStateRef(root)[]) == root

      db.delState(ConsensusFork.Fulu, root)
      check:
        not db.containsState(root)
        db.getFuluStateRef(root).isNil

    db.close()

  test "sanity check phase 0 states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (phase0.BeaconStateRef)()

    for state in testStatesPhase0:
      let root = state[].phase0Data.root
      db.putState(root, state[].phase0Data.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Phase0, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check Altair states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (altair.BeaconStateRef)()

    for state in testStatesAltair:
      let root = state[].altairData.root
      db.putState(root, state[].altairData.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Altair, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check Bellatrix states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (bellatrix.BeaconStateRef)()

    for state in testStatesBellatrix:
      let root = state[].bellatrixData.root
      db.putState(root, state[].bellatrixData.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Bellatrix, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check Capella states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (capella.BeaconStateRef)()

    for state in testStatesCapella:
      let root = state[].capellaData.root
      db.putState(root, state[].capellaData.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Capella, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check Deneb states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (deneb.BeaconStateRef)()

    for state in testStatesDeneb:
      let root = state[].denebData.root
      db.putState(root, state[].denebData.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Deneb, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check Electra states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (electra.BeaconStateRef)()

    for state in testStatesElectra:
      let root = state[].electraData.root
      db.putState(root, state[].electraData.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Electra, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check Fulu states, reusing buffers" & preset():
    let db = makeTestDB(SLOTS_PER_EPOCH)
    let stateBuffer = (fulu.BeaconStateRef)()

    for state in testStatesFulu:
      let root = state[].fuluData.root
      db.putState(root, state[].fuluData.data)

      check:
        db.getState(root, stateBuffer[], noRollback)
        db.containsState(root)
        hash_tree_root(stateBuffer[]) == root

      db.delState(ConsensusFork.Fulu, root)
      check:
        not db.containsState(root)
        not db.getState(root, stateBuffer[], noRollback)

    db.close()

  test "sanity check phase 0 getState rollback" & preset():
    var
      db = makeTestDB(SLOTS_PER_EPOCH)
      validatorMonitor = newClone(ValidatorMonitor.init())
      dag = init(ChainDAGRef, defaultRuntimeConfig, db, validatorMonitor, {})
      state = (ref ForkedHashedBeaconState)(
        kind: ConsensusFork.Phase0,
        phase0Data: phase0.HashedBeaconState(data: phase0.BeaconState(
          slot: 10.Slot)))
      root = Eth2Digest()

    db.putCorruptState(ConsensusFork.Phase0, root)

    let restoreAddr = addr dag.headState

    func restore() =
      assign(state[], restoreAddr[])

    check:
      state[].phase0Data.data.slot == 10.Slot
      not db.getState(root, state[].phase0Data.data, restore)
      state[].phase0Data.data.slot != 10.Slot

  test "sanity check Altair and cross-fork getState rollback" & preset():
    var
      db = makeTestDB(SLOTS_PER_EPOCH)
      validatorMonitor = newClone(ValidatorMonitor.init())
      dag = init(ChainDAGRef, defaultRuntimeConfig, db, validatorMonitor, {})
      state = (ref ForkedHashedBeaconState)(
        kind: ConsensusFork.Altair,
        altairData: altair.HashedBeaconState(data: altair.BeaconState(
          slot: 10.Slot)))
      root = Eth2Digest()

    db.putCorruptState(ConsensusFork.Altair, root)

    let restoreAddr = addr dag.headState

    func restore() =
      assign(state[], restoreAddr[])

    check:
      state[].altairData.data.slot == 10.Slot
      not db.getState(root, state[].altairData.data, restore)
=======
        db.delBlock(consensusFork, root)
        not db.containsBlock(root)
      withAll(ConsensusFork):
        check not db.containsBlock(root, consensusFork.TrustedSignedBeaconBlock)
      check:
        db.getBlock(root, consensusFork.TrustedSignedBeaconBlock).isErr()
        not db.getBlockSSZ(root, tmp, consensusFork.TrustedSignedBeaconBlock)
        not db.getBlockSZ(root, tmp2, consensusFork.TrustedSignedBeaconBlock)

      db.putStateRoot(root, signedBlock.message.slot, root)
      var root2 = root
      root2.data[0] = root.data[0] + 1
      db.putStateRoot(root, signedBlock.message.slot + 1, root2)

      check:
        db.getStateRoot(root, signedBlock.message.slot).get() == root
        db.getStateRoot(root, signedBlock.message.slot + 1).get() == root2

      db.close()

  withAll(ConsensusFork):
    let name = "sanity check " & $consensusFork & " blocks"
    test name & preset():
      when consensusFork >= ConsensusFork.Gloas:
        skip()
      else:
        consensusFork.doBlockTest()

  template doStateTest(consensusFork: static ConsensusFork): untyped =
    block:
      let db = cfg.makeTestDB(SLOTS_PER_EPOCH)

      for state in testStates[consensusFork]:
        let root = state[].forky(consensusFork).root
        db.putState(root, state[].forky(consensusFork).data)

        check:
          db.containsState(root)
          hash_tree_root(db.getStateRef(consensusFork, root)[]) == root

        db.delState(consensusFork, root)
        check:
          not db.containsState(root)
          db.getStateRef(consensusFork, root).isNil

      db.close()

  withAll(ConsensusFork):
    let name = "sanity check " & $consensusFork & " states"
    test name & preset():
      when consensusFork >= ConsensusFork.Gloas:
        skip()
      else:
        consensusFork.doStateTest()

  template doStateTestReusingBuffers(
      consensusFork: static ConsensusFork): untyped =
    block:
      let
        db = cfg.makeTestDB(SLOTS_PER_EPOCH)
        stateBuffer = (consensusFork.BeaconStateRef)()

      for state in testStates[consensusFork]:
        let root = state[].forky(consensusFork).root
        db.putState(root, state[].forky(consensusFork).data)

        check:
          db.getState(root, stateBuffer[], noRollback)
          db.containsState(root)
          hash_tree_root(stateBuffer[]) == root

        db.delState(consensusFork, root)
        check:
          not db.containsState(root)
          not db.getState(root, stateBuffer[], noRollback)

      db.close()

  withAll(ConsensusFork):
    let name = "sanity check " & $consensusFork & " states, reusing buffers"
    test name & preset():
      when consensusFork >= ConsensusFork.Gloas:
        skip()
      else:
        consensusFork.doStateTestReusingBuffers()

  template doRollbackTest(consensusFork: static ConsensusFork): untyped =
    block:
      var
        db = cfg.makeTestDB(SLOTS_PER_EPOCH)
        validatorMonitor = newClone(ValidatorMonitor.init(cfg.time))
        dag = init(ChainDAGRef, cfg, db, validatorMonitor, {})
        state = ForkedHashedBeaconState.new(
          (ref consensusFork.BeaconState)(slot: 10.Slot)[])
        root = Eth2Digest()

      db.putCorruptState(consensusFork, root)

      let restoreAddr = addr dag.headState

      func restore() =
        assign(state[], restoreAddr[])

      withState(state[]):
        check:
          forkyState.data.slot == 10.Slot
          not db.getState(root, forkyState.data, restore)
>>>>>>> origin/unstable

      # assign() has switched the case object fork
      check:
        state[].kind == ConsensusFork.Phase0
        state[].phase0Data.data.slot != 10.Slot

  withAll(ConsensusFork):
    let name = "sanity check " & $consensusFork &
      (if consensusFork > ConsensusFork.Phase0: " and cross-fork" else: "") &
      " getState rollback"
    test name & preset():
      when consensusFork >= ConsensusFork.Gloas:
        skip()
      else:
        consensusFork.doRollbackTest()

  test "sanity check Fulu and cross-fork getState rollback" & preset():
    var
      db = makeTestDB(SLOTS_PER_EPOCH)
      validatorMonitor = newClone(ValidatorMonitor.init())
      dag = init(ChainDAGRef, defaultRuntimeConfig, db, validatorMonitor, {})
      state = (ref ForkedHashedBeaconState)(
        kind: ConsensusFork.Fulu,
        fuluData: fulu.HashedBeaconState(data: fulu.BeaconState(
          slot: 10.Slot)))
      root = Eth2Digest()

    db.putCorruptState(ConsensusFork.Fulu, root)

    let restoreAddr = addr dag.headState

    func restore() =
      assign(state[], restoreAddr[])

    check:
      state[].fuluData.data.slot == 10.Slot
      not db.getState(root, state[].fuluData.data, restore)

      # assign() has switched the case object fork
      state[].kind == ConsensusFork.Phase0
      state[].phase0Data.data.slot != 10.Slot

  test "find ancestors" & preset():
    var db = BeaconChainDB.new("", cfg, inMemory = true)

    let
      a0 = withDigest(
        (phase0.TrustedBeaconBlock)(slot: GENESIS_SLOT + 0))
      a1 = withDigest(
        (phase0.TrustedBeaconBlock)(slot: GENESIS_SLOT + 1, parent_root: a0.root))
      a2 = withDigest(
        (phase0.TrustedBeaconBlock)(slot: GENESIS_SLOT + 2, parent_root: a1.root))

    doAssert toSeq(db.getAncestorSummaries(a0.root)).len == 0
    doAssert toSeq(db.getAncestorSummaries(a2.root)).len == 0
    doAssert db.getBeaconBlockSummary(a2.root).isNone()

    db.putBlock(a2)

    doAssert toSeq(db.getAncestorSummaries(a0.root)).len == 0
    doAssert toSeq(db.getAncestorSummaries(a2.root)).len == 1
    doAssert db.getBeaconBlockSummary(a2.root).get().slot == a2.message.slot

    db.putBlock(a1)

    doAssert toSeq(db.getAncestorSummaries(a0.root)).len == 0
    doAssert toSeq(db.getAncestorSummaries(a2.root)).len == 2

    db.putBlock(a0)

    doAssert toSeq(db.getAncestorSummaries(a0.root)).len == 1
    doAssert toSeq(db.getAncestorSummaries(a2.root)).len == 3

  test "sanity check genesis roundtrip" & preset():
    # This is a really dumb way of checking that we can roundtrip a genesis
    # state. We've been bit by this because we've had a bug in the BLS
    # serialization where an all-zero default-initialized bls signature could
    # not be deserialized because the deserialization was too strict.
    var db = BeaconChainDB.new("", cfg, inMemory = true)

    let
      state = newClone(initialize_hashed_beacon_state_from_eth1(
        cfg, mockEth1BlockHash, 0,
        makeInitialDeposits(SLOTS_PER_EPOCH), {skipBlsValidation}))

    db.putState(state[].root, state[].data)

    check db.containsState(state[].root)
    let state2 = db.getStateRef(ConsensusFork.Phase0, state[].root)
    db.delState(ConsensusFork.Phase0, state[].root)
    check not db.containsState(state[].root)
    db.close()

    check:
      hash_tree_root(state2[]) == state[].root

  test "sanity check state diff roundtrip" & preset():
    var db = BeaconChainDB.new("", cfg, inMemory = true)

    # TODO htr(diff) probably not interesting/useful, but stand-in
    let
      stateDiff = BeaconStateDiff()
      root = hash_tree_root(stateDiff)

    db.putStateDiff(root, stateDiff)

    let state2 = db.getStateDiff(root)
    db.delStateDiff(root)
    check db.getStateDiff(root).isNone()
    db.close()

    check:
      hash_tree_root(state2[]) == root

  test "sanity check blobs" & preset():
    const
      blockHeader0 = SignedBeaconBlockHeader(
        message: BeaconBlockHeader(slot: Slot(0)))
      blockHeader1 = SignedBeaconBlockHeader(
        message: BeaconBlockHeader(slot: Slot(1)))

    let
      blockRoot0 = hash_tree_root(blockHeader0.message)
      blockRoot1 = hash_tree_root(blockHeader1.message)

      # Ensure minimal-difference pairs on both block root and blob index to
      # verify that blobkey uses both
      blobSidecar0 = BlobSidecar(signed_block_header: blockHeader0, index: 3)
      blobSidecar1 = BlobSidecar(signed_block_header: blockHeader0, index: 2)
      blobSidecar2 = BlobSidecar(signed_block_header: blockHeader1, index: 2)

      db = cfg.makeTestDB(SLOTS_PER_EPOCH)

    var
      buf: seq[byte]
      blobSidecar: BlobSidecar

    check:
      not db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      not db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      not db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      not db.getBlobSidecarSZ(blockRoot0, 3, buf)
      not db.getBlobSidecarSZ(blockRoot0, 2, buf)
      not db.getBlobSidecarSZ(blockRoot1, 2, buf)

    db.putBlobSidecar(blobSidecar0)

    check:
      db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      blobSidecar == blobSidecar0
      not db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      not db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      db.getBlobSidecarSZ(blockRoot0, 3, buf)
      not db.getBlobSidecarSZ(blockRoot0, 2, buf)
      not db.getBlobSidecarSZ(blockRoot1, 2, buf)

    db.putBlobSidecar(blobSidecar1)

    check:
      db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      blobSidecar == blobSidecar0
      db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      blobSidecar == blobSidecar1
      not db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      db.getBlobSidecarSZ(blockRoot0, 3, buf)
      db.getBlobSidecarSZ(blockRoot0, 2, buf)
      not db.getBlobSidecarSZ(blockRoot1, 2, buf)

    check db.delBlobSidecar(blockRoot0, 3)

    check:
      not db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      blobSidecar == blobSidecar1
      not db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      not db.getBlobSidecarSZ(blockRoot0, 3, buf)
      db.getBlobSidecarSZ(blockRoot0, 2, buf)
      not db.getBlobSidecarSZ(blockRoot1, 2, buf)

    db.putBlobSidecar(blobSidecar2)

    check:
      not db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      blobSidecar == blobSidecar1
      db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      blobSidecar == blobSidecar2
      not db.getBlobSidecarSZ(blockRoot0, 3, buf)
      db.getBlobSidecarSZ(blockRoot0, 2, buf)
      db.getBlobSidecarSZ(blockRoot1, 2, buf)

    check db.delBlobSidecar(blockRoot0, 2)

    check:
      not db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      not db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      blobSidecar == blobSidecar2
      not db.getBlobSidecarSZ(blockRoot0, 3, buf)
      not db.getBlobSidecarSZ(blockRoot0, 2, buf)
      db.getBlobSidecarSZ(blockRoot1, 2, buf)

    check db.delBlobSidecar(blockRoot1, 2)

    check:
      not db.getBlobSidecar(blockRoot0, 3, blobSidecar)
      not db.getBlobSidecar(blockRoot0, 2, blobSidecar)
      not db.getBlobSidecar(blockRoot1, 2, blobSidecar)
      not db.getBlobSidecarSZ(blockRoot0, 3, buf)
      not db.getBlobSidecarSZ(blockRoot0, 2, buf)
      not db.getBlobSidecarSZ(blockRoot1, 2, buf)

    db.close()

  test "sanity check data columns" & preset():
    const
      blockHeader0 = SignedBeaconBlockHeader(
        message: BeaconBlockHeader(slot: Slot(0)))
      blockHeader1 = SignedBeaconBlockHeader(
        message: BeaconBlockHeader(slot: Slot(1)))

    let
      blockRoot0 = hash_tree_root(blockHeader0.message)
      blockRoot1 = hash_tree_root(blockHeader1.message)

<<<<<<< HEAD
      # Ensure minimal-difference pairs on both block root and 
      # data column index to verify that the columnkey uses both
      dataColumnSidecar0 = DataColumnSidecar(signed_block_header: blockHeader0, index: 3)
      dataColumnSidecar1 = DataColumnSidecar(signed_block_header: blockHeader0, index: 2)
      dataColumnSidecar2 = DataColumnSidecar(signed_block_header: blockHeader1, index: 2)

      db = makeTestDB(SLOTS_PER_EPOCH)

    var
      buf: seq[byte]
      dataColumnSidecar: DataColumnSidecar
=======
      # Ensure minimal-difference pairs on both block root and
      # data column index to verify that the columnkey uses both
      dataColumnSidecar0 = fulu.DataColumnSidecar(signed_block_header: blockHeader0, index: 3)
      dataColumnSidecar1 = fulu.DataColumnSidecar(signed_block_header: blockHeader0, index: 2)
      dataColumnSidecar2 = fulu.DataColumnSidecar(signed_block_header: blockHeader1, index: 2)

      db = cfg.makeTestDB(SLOTS_PER_EPOCH)

    var
      buf: seq[byte]
      dataColumnSidecar: fulu.DataColumnSidecar
>>>>>>> origin/unstable

    check:
      not db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      not db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      not db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      not db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      not db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      not db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    db.putDataColumnSidecar(dataColumnSidecar0)
<<<<<<< HEAD
    
=======

>>>>>>> origin/unstable
    check:
      db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar0
      not db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      not db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      not db.getDataColumnSidecarSZ(blockRoot0, 2, buf)
      not db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    db.putDataColumnSidecar(dataColumnSidecar1)

    check:
      db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar0
      db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar1
      not db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      db.getDataColumnSidecarSZ(blockRoot0, 2, buf)
      not db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    check db.delDataColumnSidecar(blockRoot0, 3)

    check:
      not db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar1
      not db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      not db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      db.getDataColumnSidecarSZ(blockRoot0, 2, buf)
      not db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    db.putDataColumnSidecar(dataColumnSidecar2)

    check:
      not db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar1
      db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar2
      not db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      db.getDataColumnSidecarSZ(blockRoot0, 2, buf)
      db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    check db.delDataColumnSidecar(blockRoot0, 2)

    check:
      not db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      not db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      dataColumnSidecar == dataColumnSidecar2
      not db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      not db.getDataColumnSidecarSZ(blockRoot0, 2, buf)
      db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    check db.delDataColumnSidecar(blockRoot1, 2)

    check:
      not db.getDataColumnSidecar(blockRoot0, 3, dataColumnSidecar)
      not db.getDataColumnSidecar(blockRoot0, 2, dataColumnSidecar)
      not db.getDataColumnSidecar(blockRoot1, 2, dataColumnSidecar)
      not db.getDataColumnSidecarSZ(blockRoot0, 3, buf)
      not db.getDataColumnSidecarSZ(blockRoot0, 2, buf)
      not db.getDataColumnSidecarSZ(blockRoot1, 2, buf)

    db.close()

<<<<<<< HEAD
=======
suite "Quarantine" & preset():
  setup:
    let
      db = BeaconChainDB.new("", cfg, inMemory = true)
      quarantine = db.getQuarantineDB()

  teardown:
    db.close()

  func genBlockRoot(index: int): Eth2Digest =
    var res: Eth2Digest
    let tmp = uint64(index).toBytesLE()
    copyMem(addr res.data[0], unsafeAddr tmp[0], sizeof(uint64))
    res

  func genKzgCommitment(index: int): KzgCommitment =
    var res: KzgCommitment
    let tmp = uint64(index).toBytesLE()
    copyMem(addr res.bytes[0], unsafeAddr tmp[0], sizeof(uint64))
    res

  func genBlobSidecar(
      index: int,
      slot: int,
      kzg_commitment: int,
      proposer_index: int
  ): BlobSidecar =
    BlobSidecar(
      index: BlobIndex(index),
      kzg_commitment: genKzgCommitment(kzg_commitment),
      signed_block_header: SignedBeaconBlockHeader(
        message: BeaconBlockHeader(
          slot: Slot(slot),
          proposer_index: uint64(proposer_index))))

  func genDataColumnSidecar(
      index: int,
      slot: int,
      proposer_index: int
  ): fulu.DataColumnSidecar =
    fulu.DataColumnSidecar(
      index: ColumnIndex(index),
      signed_block_header: SignedBeaconBlockHeader(
        message: BeaconBlockHeader(
          slot: Slot(slot),
          proposer_index: uint64(proposer_index))))

  proc cmp(
      a: openArray[ref BlobSidecar|ref fulu.DataColumnSidecar],
      b: openArray[ref BlobSidecar|ref fulu.DataColumnSidecar]
  ): bool =
    if len(a) != len(b):
      return false
    for index in 0 ..< len(a):
      if a[index][] != b[index][]:
        return false
    true

  proc generateBlobSidecars(): seq[ref BlobSidecar] =
    @[
      newClone(genBlobSidecar(0, 100, 10, 24)),
      newClone(genBlobSidecar(1, 100, 11, 24)),
      newClone(genBlobSidecar(2, 100, 12, 24)),
      newClone(genBlobSidecar(3, 100, 13, 24)),
      newClone(genBlobSidecar(4, 100, 14, 24)),
      newClone(genBlobSidecar(5, 100, 15, 24)),
      newClone(genBlobSidecar(6, 100, 16, 24)),
      newClone(genBlobSidecar(7, 100, 17, 24)),
      newClone(genBlobSidecar(8, 100, 18, 24))
    ]

  proc generateDataColumnSidecars(): seq[ref fulu.DataColumnSidecar] =
    @[
      newClone(genDataColumnSidecar(0, 200, 100234)),
      newClone(genDataColumnSidecar(7, 200, 100234)),
      newClone(genDataColumnSidecar(14, 200, 100234)),
      newClone(genDataColumnSidecar(21, 200, 100234)),
      newClone(genDataColumnSidecar(28, 200, 100234)),
      newClone(genDataColumnSidecar(35, 200, 100234)),
      newClone(genDataColumnSidecar(42, 200, 100234)),
      newClone(genDataColumnSidecar(49, 200, 100234)),
      newClone(genDataColumnSidecar(56, 200, 100234)),
      newClone(genDataColumnSidecar(63, 200, 100234)),
      newClone(genDataColumnSidecar(70, 200, 100234)),
      newClone(genDataColumnSidecar(77, 200, 100234)),
      newClone(genDataColumnSidecar(84, 200, 100234)),
      newClone(genDataColumnSidecar(91, 200, 100234)),
      newClone(genDataColumnSidecar(98, 200, 100234)),
      newClone(genDataColumnSidecar(127, 200, 100234)),
    ]

  proc getSidecars(
      quarantine: QuarantineDB,
      T: typedesc[BlobSidecar|fulu.DataColumnSidecar],
      blockRoot: Eth2Digest
  ): seq[ref T] =
    var res: seq[ref T]
    for item in quarantine.sidecars(T, blockRoot):
      res.add(newClone(item))
    res

  proc runDataSidecarTest(
      quarantine: QuarantineDB,
      T: typedesc[ForkyDataSidecar]
  ) =
    let
      broots = @[
        genBlockRoot(100), genBlockRoot(200), genBlockRoot(300)
      ]
      sidecars =
        when T is deneb.BlobSidecar:
          generateBlobSidecars()
        else:
          generateDataColumnSidecars()
      offsets =
        when T is deneb.BlobSidecar:
          @[(0, 8), (0, 3), (0, 5)]
        else:
          @[(0, 15), (4, 11), (0, 7)]

    check:
      len(quarantine.getSidecars(T, broots[0])) == 0
      len(quarantine.getSidecars(T, broots[1])) == 0
      len(quarantine.getSidecars(T, broots[2])) == 0
      quarantine.sidecarsCount(T) == 0

    quarantine.removeDataSidecars(T, broots[0])
    quarantine.removeDataSidecars(T, broots[1])
    quarantine.removeDataSidecars(T, broots[2])

    quarantine.putDataSidecars(broots[0],
      sidecars.toOpenArray(offsets[0][0], offsets[0][1]))

    block:
      let
        res1 = quarantine.getSidecars(T, broots[0])
      check:
        quarantine.sidecarsCount(T) == len(res1)
        len(res1) == (offsets[0][1] - offsets[0][0] + 1)
        cmp(res1, sidecars.toOpenArray(offsets[0][0], offsets[0][1])) == true
        len(quarantine.getSidecars(T, broots[1])) == 0
        len(quarantine.getSidecars(T, broots[2])) == 0

    quarantine.putDataSidecars(broots[1],
      sidecars.toOpenArray(offsets[1][0], offsets[1][1]))

    block:
      let
        res1 = quarantine.getSidecars(T, broots[0])
        res2 = quarantine.getSidecars(T, broots[1])
      check:
        quarantine.sidecarsCount(T) == len(res1) + len(res2)
        len(res1) == (offsets[0][1] - offsets[0][0] + 1)
        len(res2) == (offsets[1][1] - offsets[1][0] + 1)
        cmp(res1, sidecars.toOpenArray(offsets[0][0], offsets[0][1])) == true
        cmp(res2, sidecars.toOpenArray(offsets[1][0], offsets[1][1])) == true
        len(quarantine.getSidecars(T, broots[2])) == 0

    quarantine.putDataSidecars(broots[2],
      sidecars.toOpenArray(offsets[2][0], offsets[2][1]))

    block:
      let
        res1 = quarantine.getSidecars(T, broots[0])
        res2 = quarantine.getSidecars(T, broots[1])
        res3 = quarantine.getSidecars(T, broots[2])
      check:
        len(res1) == (offsets[0][1] - offsets[0][0] + 1)
        len(res2) == (offsets[1][1] - offsets[1][0] + 1)
        len(res3) == (offsets[2][1] - offsets[2][0] + 1)
        quarantine.sidecarsCount(T) == len(res1) + len(res2) + len(res3)
        cmp(res1, sidecars.toOpenArray(offsets[0][0], offsets[0][1])) == true
        cmp(res2, sidecars.toOpenArray(offsets[1][0], offsets[1][1])) == true
        cmp(res3, sidecars.toOpenArray(offsets[2][0], offsets[2][1])) == true

    quarantine.removeDataSidecars(T, broots[1])

    block:
      let
        res1 = quarantine.getSidecars(T, broots[0])
        res3 = quarantine.getSidecars(T, broots[2])
      check:
        len(res1) == (offsets[0][1] - offsets[0][0] + 1)
        cmp(res1, sidecars.toOpenArray(offsets[0][0], offsets[0][1])) == true
        len(quarantine.getSidecars(T, broots[1])) == 0
        len(res3) == (offsets[2][1] - offsets[2][0] + 1)
        cmp(res3, sidecars.toOpenArray(offsets[2][0], offsets[2][1])) == true
        quarantine.sidecarsCount(T) == len(res1) + len(res3)

    quarantine.removeDataSidecars(T, broots[0])

    block:
      let
        res3 = quarantine.getSidecars(T, broots[2])
      check:
        len(quarantine.getSidecars(T, broots[0])) == 0
        len(quarantine.getSidecars(T, broots[1])) == 0
        len(res3) == (offsets[2][1] - offsets[2][0] + 1)
        cmp(res3, sidecars.toOpenArray(offsets[2][0], offsets[2][1])) == true
        quarantine.sidecarsCount(T) == len(res3)

    quarantine.removeDataSidecars(T, broots[2])

    check:
      len(quarantine.getSidecars(T, broots[0])) == 0
      len(quarantine.getSidecars(T, broots[1])) == 0
      len(quarantine.getSidecars(T, broots[2])) == 0
      quarantine.sidecarsCount(T) == 0

  test "put/iterate/remove test [BlobSidecars]":
    quarantine.runDataSidecarTest(deneb.BlobSidecar)

  test "put/iterate/remove test [DataColumnSidecar]":
    quarantine.runDataSidecarTest(fulu.DataColumnSidecar)

>>>>>>> origin/unstable
suite "FinalizedBlocks" & preset():
  test "Basic ops" & preset():
    var
      db = SqStoreRef.init("", "test", inMemory = true).expect(
        "working database (out of memory?)")

    var s = FinalizedBlocks.init(db, "finalized_blocks").get()

    check:
      s.low.isNone
      s.high.isNone

    s.insert(Slot 0, ZERO_HASH)
    check:
      s.low.get() == Slot 0
      s.high.get() == Slot 0

    s.insert(Slot 5, ZERO_HASH)
    check:
      s.low.get() == Slot 0
      s.high.get() == Slot 5

    var items = 0
    for k, v in s:
      check: k in [Slot 0, Slot 5]
      items += 1

    check: items == 2
