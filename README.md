# Sui Onchain ECDH

Supporting for on-chain interection between cipher messages. ECDH computed off-chain.

## Flow

Alice and Bob ready to send private message on chain.

1. Alice uses ECDH cryptography to create keypair (private key, public key) off-chain
2. Alice interactives Sui client to call `send_key` by `onchain_ecdh` module on-chain with arguments `(Alice)public_key`
3. object status change into 1
4. Bob checks own onchain_ecdh board objects by Sui client, find out self key field match the Bob's account address
5. Bob did step 1 the same thing (private_key, public_key) off-chain
6. Bob interactives Sui client to call `reply_key` with arguments `(Bob)public_key`
7. object status change into 2
8. they uses public_key(from other side) to compute last `secret`
9. now they got the same secret key.

\*\* Alice can destory object anytime.

## Example

[Testnet object example](https://explorer.sui.io/object/0x4f190fef268b6d8349bd28ce946f985f9c1ca8a6)

#### Properties

`public_key`

> 04019087775db9626a9bce35216f80a034485183a7beb0fe633fb0f607454ffd814689317a80036f17fa0319345827314fd1086507e179b35f448d0571c6d6bed0ae3401fcf2c94c5ec5dec3c689c19a8b1db4ce1e6c792b5d07dddf0fa2bf1937d8d06e3b88582fafefb50251129e219f390b2307b233b9622d5cd88747adfcb87a9c9f20

`other_public_key(*instead of reply_public_key)`

> 0401dfdacc786f6e3aa70367988f115f9ecdf6db16b2545510f0ffdae486875fbc116a2cec7119b3485e16a8e1412171834baa1ab98c6eadcf5d605f1b3cf80beb7b9900d02e777d8f6b845df6d37ee9851ad3ba638b36cfdcc6aec5032325e392354726d85fe860e44c57366871b644395aefd7fb9aef82cf39f35791628d1edc74dce4a3

`sender`

> 0xad8168438da04c1b0ab4936ac99cd0640daf3f02

`status`

> 2
