
(* Globals *)


let read_len: int = 256


(* Helper Functions *)


let root_dir (): string =
    let res = begin
        let home_dir = Sys.getenv "HOME" in
        Sys.getenv_opt "FSDB_ROOT" |>
        Option.value ~default:(home_dir ^ "/.fsdb")
    end in
    if Sys.file_exists res then res else
    (Sys.mkdir res 0o777; res)


let get_file (id: string): string =
    (root_dir ()) ^ "/" ^ id


let handle_unix_error (f: 'a -> 'b) (a: 'a): ('b, string) result =
    try
        Ok (f a)
    with
        | Unix.Unix_error (er, _, _) -> Error (Unix.error_message er)


let print_error (msg: string) =
    Printf.printf "[FSDB] ERROR: %s" msg


let ( let* ) r f =
    match r with
        | Ok a -> a
        | Error e -> print_error e


let get_fd (id: string) (flags: Unix.open_flag list): (Unix.file_descr, string) result =
    let rf () = Unix.openfile (get_file id) flags  0o666 in
    handle_unix_error rf ()

let read (fd: Unix.file_descr) (data: Bytes.t) (pos: int) (read_len: int): (int, string) result =
    let rf () = Unix.read fd data pos read_len in
    handle_unix_error rf ()

let rec read_into_buffer (buffer: Buffer.t) (fd: Unix.file_descr) (pos: int): Buffer.t =
    let data = Bytes.create read_len in
    let* len = read fd data pos read_len in
    if len < 0 then buffer else
    if len = 0 then buffer else begin
        Buffer.add_bytes buffer data;
        read_into_buffer buffer fd (pos + len)
    end

(* Module Functions *)


let store (id, data) =
    let* fd = get_fd id [Unix.O_WRONLY; Unix.O_TRUNC; Unix.O_CREAT] in
    Unix.lockf fd Unix.F_LOCK 0;

    let _ = Unix.write fd data 0 (Bytes.length data) in

    Unix.lockf fd Unix.F_ULOCK 0;
    Unix.close fd



let load (id: string): bytes =

    if not @@ Sys.file_exists (get_file id) then Bytes.empty else

    let fd = get_fd id [Unix.O_RDONLY; Unix.O_CREAT] in
    Unix.lockf fd Unix.F_RLOCK 0;

    let res =
        Buffer.create read_len
        |> fun x -> read_into_buffer x fd 0
        |> Buffer.to_bytes
    in

    Unix.lockf fd Unix.F_ULOCK 0;
    Unix.close fd;
    res
