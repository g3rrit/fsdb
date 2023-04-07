
external _store : string -> bytes -> int -> bool = "store_wrapper"

external _load : string -> bytes Option.t = "load_wrapper"

let store (id: string) (data: bytes): bool =
    _store id data (Bytes.length data)

let load (id: string): bytes Option.t =
    _load id
