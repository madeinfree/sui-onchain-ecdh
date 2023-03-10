module onchain_ecdh::onchain_ecdh {

  use std::string::{Self, String};
  use std::vector;

  use sui::object::{Self, ID, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use sui::dynamic_object_field as dof;
  use sui::address;
  use sui::event::emit;

  struct PublicKeyBoard has key {
    id: UID
  }

  struct Exchange has key, store {
    id: UID,
    sender: address,
    public_key: String,
    reply_public_key: String,
    status: u8
  }

  ////////////////////////////////// Event //////////////////////////////////
  struct BoardCreate has copy, drop {
    id: ID,
    creator: address
  }

  struct SendKey has copy, drop {
    id: ID,
    sender: address,
    receiver: address,
    public_key: String
  }

  struct ReplyKey has copy, drop {
    id: ID,
    reply_public_key: String
  }

  struct DestoryKey has copy, drop {
    id: ID
  }

  const EExchangeNotInBoard: u64 = 0;
  const EExchangeStatusIncorrect: u64 = 1;
  const EShouldBeKeySender: u64 = 10;
  const EExchangeInBoard: u64 = 20;

  fun init(ctx: &mut TxContext) {
    let id = object::new(ctx);
    let sender = tx_context::sender(ctx);

    emit(BoardCreate {
      id: object::uid_to_inner(&id),
      creator: sender
    });

    let public_key_board = PublicKeyBoard {
      id
    };

    transfer::share_object(public_key_board);
  }
  
  ////////////////// allow to create new public key board ////////////////////
  public fun create_new_board(ctx: &mut TxContext) {
    let id = object::new(ctx);
    let sender = tx_context::sender(ctx);

    emit(BoardCreate {
      id: object::uid_to_inner(&id),
      creator: sender
    });

    let public_key_board = PublicKeyBoard {
      id
    };

    transfer::share_object(public_key_board)
  }

  public entry fun send_key(public_key_board: &mut PublicKeyBoard, public_key: String, receiver: address, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(!dof::exists_(&public_key_board.id, address::to_string(receiver)), EExchangeInBoard);
    let id = object::new(ctx);

    emit(SendKey {
      id: object::uid_to_inner(&id),
      sender,
      receiver,
      public_key
    });

    dof::add(
      &mut public_key_board.id,
      address::to_string(receiver),
      Exchange {
        id,
        sender,
        public_key,
        reply_public_key: string::utf8(vector::empty()),
        status: 1
      }
    ); 
  }

  public entry fun reply_key(public_key_board: &mut PublicKeyBoard, reply_public_key: String, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(dof::exists_(&public_key_board.id, address::to_string(sender)), EExchangeNotInBoard);
    let exchange = dof::remove<String, Exchange>(&mut public_key_board.id, address::to_string(sender));
    assert!(exchange.status == 1, EExchangeStatusIncorrect);
    exchange.status = 2;
    exchange.reply_public_key = reply_public_key;

    emit(ReplyKey {
      id: object::uid_to_inner(&exchange.id),
      reply_public_key
    });

    dof::add(
      &mut public_key_board.id,
      address::to_string(sender),
      exchange
    );
  }

  public entry fun destory_key(public_key_board: &mut PublicKeyBoard, receiver: address, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(dof::exists_(&public_key_board.id, address::to_string(receiver)), EExchangeNotInBoard);
    let Exchange { id, sender: _, public_key: _, reply_public_key: _, status: _} = dof::remove<String, Exchange>(&mut public_key_board.id, address::to_string(sender));
    assert!(sender == sender, EShouldBeKeySender);

    emit(DestoryKey {
      id: object::uid_to_inner(&id)
    });

    object::delete(id);
  }
}