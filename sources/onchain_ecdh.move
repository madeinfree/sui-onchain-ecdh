module onchain_ecdh::onchain_ecdh {

  use std::string::{Self, String};
  use std::vector;

  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use sui::dynamic_object_field as dof;
  use sui::address;

  struct PublicKeyBoard has key {
    id: UID
  }

  struct Exchange has key, store {
    id: UID,
    sender: address,
    public_key: String,
    other_public_key: String,
    status: u8
  }

  const EExchangeNotInBoard: u64 = 0;
  const EExchangeStatusIncorrect: u64 = 1;
  const EShouldBeKeySender: u64 = 10;
  const EExchangeInBoard: u64 = 20;

  fun init(ctx: &mut TxContext) {
    let public_key_board = PublicKeyBoard {
      id: object::new(ctx)
    };

    transfer::share_object(public_key_board);
  }

  public entry fun send_key(public_key_board: &mut PublicKeyBoard, public_key: String, receiver: address, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(!dof::exists_(&public_key_board.id, address::to_string(receiver)), EExchangeInBoard);
    dof::add(
      &mut public_key_board.id,
      address::to_string(receiver),
      Exchange {
        id: object::new(ctx),
        sender,
        public_key,
        other_public_key: string::utf8(vector::empty()),
        status: 1
      }
    );
  }

  public entry fun resend_key(public_key_board: &mut PublicKeyBoard, other_public_key: String, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(dof::exists_(&public_key_board.id, address::to_string(sender)), EExchangeNotInBoard);
    let exchange = dof::remove<String, Exchange>(&mut public_key_board.id, address::to_string(sender));
    assert!(exchange.status == 1, EExchangeStatusIncorrect);
    exchange.status = 2;
    exchange.other_public_key = other_public_key;
    dof::add(
      &mut public_key_board.id,
      address::to_string(sender),
      exchange
    );
  }

  public entry fun destory_key(public_key_board: &mut PublicKeyBoard, receiver: address, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(dof::exists_(&public_key_board.id, address::to_string(receiver)), EExchangeNotInBoard);
    let Exchange { id, sender: _, public_key: _, other_public_key: _, status: _} = dof::remove<String, Exchange>(&mut public_key_board.id, address::to_string(sender));
    assert!(sender == sender, EShouldBeKeySender);

    object::delete(id);
  }
}