import Foundation

/// SHA-256 of every bundled content file as currently present in the repository.
/// The original JS-era baseline digests are preserved in
/// `openspec/changes/migrate-to-native-swift/baseline/parity-data.json` and must not
/// be silently overwritten; updates here must be traceable to an approved copy change.
/// See `openspec/changes/correct-approved-polish-copy/approved-content-delta.md` for
/// the before/after hash ledger and audit ID mapping for each changed file.
enum ContentChecksums {
    static let sha256: [String: String] = [
        "behaviour/alone.json":
            "193acf85fb42e2603d4454945d80024d2ff57129bea263761c53c438aed90de7",
        "behaviour/bark-door.json":
            "72b97b0f77d877899b0003441e389ae31f11da38f2f863bc2f55733a065a1119",
        "behaviour/bark-window.json":
            "80717b6ebb94230010c68a71f968071d42d5796e308d2183a3e465ff554006f8",
        "behaviour/bolting.json":
            "9c38b96ee5c4be1363a20df74eb5eda1350705cbff28ecfc3c7b00ceb25ebb40",
        "behaviour/jumping.json":
            "e24870a52eb61b19edaba3b8c2b1070cab1b88cd06a8a7c849f2c52ff06c690d",
        "behaviour/nipping.json":
            "22a6975a175a31691e7e9f6259067d678b00be0271b0a54d4a1afb929e12786d",
        "behaviour/noise.json":
            "c722a6b2ec0f4798e5d761f4051de3d7f59b69320d8b9646ec923fa4e448767c",
        "behaviour/mounting.json":
            "139aff66965dbf77c91afae1cdbf11cc1c588a78ec7af585150c2c9f5c908736",
        "behaviour/overarousal.json":
            "72d2cdaf27eb47ee1f0af406acc9c0a38e2db07b70bed6cf1cfd9dd17247d8c4",
        "behaviour/fear-withdrawal.json":
            "b31e29e4754bd5954d941507d3ae9343cc6905503b3638533d7ceece954deac4",
        "behaviour/bed.json":
            "df9d21d9bb90d5346969d376436a0f62f5d10e9bfd1a94186fd8be3e0f340e5b",
        "behaviour/reactivity.json":
            "8fa6eff631fe51dfdb542c551ab612bd80a3fe2923da473cb43cdc1c98faf089",
        "behaviour/stealing.json":
            "2d34be846917004b1dc077ef8ebacc04d2ae103fd817fdbb9d3f8149b1fc719b",
        "behaviour/traffic.json":
            "a90257586196a86e4e633c29ae99e5152a3b300e427b52c64ef92c45683717ac",
        "care/care-paw-rinse.json":
            "b856428e641b61e1806643b0283f3674d542880f213e87e8af2e7fb97acb99f7",
        "care/care-nails.json":
            "df21184738b817c8a6f9379de169397227aebcc690ea54421117986992217a08",
        "care/care-coat.json":
            "13691d692cd173c8854b85f9de6cdb542272da55a31639cb0af4eb7f436037bb",
        "care/care-checks.json":
            "eb42b94a42ac23d68c3dac35daddfcba6d390f50c934e82dc57ece5169f99f05",
        "care/care-teeth.json":
            "39f5327a69fd886039fe3d2c354c65e746a7a037fd5af24b5ce56b914a86ec48",
        "care/care-towel.json":
            "955e37efd5b145f95ffdf7877254883dc6b69a968e5f27b280fa4e6602956518",
        "care/care-bath.json":
            "4d327bf0a127a935ea4436e8e7fbf3caca2d30972dfb4c7fdb076cc27219b176",
        "environments.json":
            "2dca9138de1f5fa19d6bad2e08e8df34996e40743a8d424ca78ec5289b9b54bb",
        "exercises/come.json":
            "0f3fad32abad482ebabe9037e34b83fe9f36014e4940b744eded2fa2ac5d700a",
        "exercises/down.json":
            "08ba829bca3c7e0f333703fda72a07adee34958aa880289cac085cfbf342cb2f",
        "exercises/drop.json":
            "12243f2cbca7693c4dbc7b8e0d0e58415f4e47daa878272133787da5691dda3e",
        "exercises/handling.json":
            "3c5377d808b5aac508b41d845f4602ae523562f3ead90e4c768ac7ac216c4c4c",
        "exercises/leash.json":
            "44b6218cce6485da82323511aaa2780e50f6f1a67f3ad3c0de2e68df910b9a1b",
        "exercises/leave.json":
            "bd7796bbb85b2740b5c38f8b024b095720996a80125184188f981360f5c76dcd",
        "exercises/look.json":
            "7d2bf5117fed4f5e20d617a608f806f4a8bace070a65cb3e8ac11322e93a78a5",
        "exercises/mat.json":
            "ae69716e84d96ee0aeb5e48bc509f2325f4df38989002d3bc9fccde8d6bfbd56",
        "exercises/name.json":
            "271f25dcf1c4519862433de4cba98ec0d7dac76dbe3577530d87ccd8e2f73b93",
        "exercises/sit.json":
            "8fb01c03e91e44533904d35aba5b10f73a89432e83bcdc9df49fcfe137717bb2",
        "exercises/stay.json":
            "e1d1418554ffc7231099ea8ff8a5d11d4abfe757b758ad470e243522c7492aae",
        "exercises/wait.json":
            "13a3cd818c918af4340a062b568b267c30c8d4ad06fbcdf0999c5aa4b54f027c",
        "mistakes/come.json":
            "cc60b0037661a7274878c86682bf7ecb534b38f860c90e5ed352d86a2a1b124c",
        "mistakes/down.json":
            "29ac6d47660ce69a67eed2cde79914b48a5441990816b554c325bf2a73d2e831",
        "mistakes/drop.json":
            "f59a00a200bb790421c53e2441987f3037ebe9fc5d80e88a7054c1e86fe28460",
        "mistakes/handling.json":
            "7b38cbc4f76121ef9697e8a8121a771a4b273c46802f71643f57ac9d8ff98b83",
        "mistakes/leash.json":
            "a52b02d751f539dc175cb731e8632e0543b433bab55ff80f66ff103b32f0ba13",
        "mistakes/leave.json":
            "137e41445ba647febbf1513444906862bf6241d422767ee25ebce74548409a54",
        "mistakes/look.json":
            "f22cb48d467d3c25cb64585ca08501815677f1516e7e22a7fb5fadf01a3840a7",
        "mistakes/mat.json":
            "7845b273f8f09964206a2fd82d86a355165ecb548a26a1fc5f5eda996fede8cf",
        "mistakes/name.json":
            "77964e8cf583916b3f6144aa01259a74378ad3211cd848bc840ab21ba3a05e57",
        "mistakes/sit.json":
            "dd09618712075dfa0996020d7e2ad354d151a8f85eb03d5d7bb0c45c6c564603",
        "mistakes/stay.json":
            "599ba7a0714306f4d1fdfdcfb103bbea99daf644c05fb3caa7166b644e57ad2c",
        "mistakes/wait.json":
            "42ae7a8bfe29f944db331bfc22164dc7c454c0119673b149ee2ed017015daf11",
        "nosework/cups.json":
            "b388dd48e470679635c43988d7f707a0dcf997f7f04c8bd38c5dddd60c2ffcaf",
        "nosework/find-person.json":
            "9584edab841f99cabf07066e578955f8c221dafadabe674af210accdd171d5a4",
        "nosework/find-toy.json":
            "285d47dd1fcdd368fb516cb8d6d4e643f99bc24f98f3f2097f64463daf9989cb",
        "nosework/scatter.json":
            "4907d6977735328de4b8998f10d3102bd35bbbd8cdd46cde2303c68d4d2fb8d5",
        "nosework/snuffle.json":
            "f8d1aa45faae44870bcdb6ae1df446915246119e529c1d53065f319e47e30a4f",
        "nosework/track.json":
            "85681b6785f6096dda9de6eedeca0d37543115a9f18bddf299a816a0cac1d941",
        // puppy-start guides. These are guidance, not scored training: the
        // digests prove the bytes bundled for offline reading match the
        // approved copy, and nothing here is seeded into scored storage.
        "puppy/puppy-rest.json":
            "191bde0052097359779afa864b18610e11ea4864e809abd6cb6c9a6f3f144f41",
        "puppy/puppy-world.json":
            "cf9580a45c145f2196b67178d97654bbce3df647cc341421f5a6101602121a21",
        "puppy/puppy-play.json":
            "3a03b3fc168cf2d918ffd04b45871ff0a333d527f709c7dee10d12edd441d77e",
        "puppy/puppy-first-exercises.json":
            "6ab7bb8f813f18b03df10b33aa4d7826986fad8df4efbd8ed19e3e4c1b302975",
        "puppy/puppy-toilet.json":
            "06ce541e5ded3eb353dbc04ae756712734e880c9be05a3da9c5d63a0be5cd945",
    ]
}
