Require Import List.
Import ListNotations.

(* --- string-like abstract type and concat axioms --- *)
Parameter string : Type.
Parameter empty_string : string.
Parameter concat : string -> string -> string.

Axiom concat_assoc : forall a b c, concat a (concat b c) = concat (concat a b) c.
Axiom concat_empty : forall s : string, concat s empty_string = s.
Axiom concat_empty_l : forall s : string, concat empty_string s = s.

(* --- types / aliases --- *)
Parameter State : Type.
Definition Key := string.
Definition Count := string.
Definition Nonce := string.
Definition Msg := string.
Definition Cipher := string.

(* --- ChaCha API --- *)
Parameter ChaCha_Encrypt : Key -> Count -> Nonce -> Msg -> string.
Parameter ChaCha_init : Key -> Count -> Nonce -> State.
Parameter ChaCha_update : Msg -> State -> (State * Cipher).
Parameter ChaCha_digest : State -> string.

(* --- assumed properties from SAW / intended axioms --- *)
Axiom update_concat :
  forall (m1 m2 : Msg) (s : State),
    ChaCha_update (concat m1 m2) s =
      let '(s1, _) := ChaCha_update m1 s in
      ChaCha_update m2 s1.

Axiom equiv_one :
  forall (m : Msg) (k : Key) (c : Count) (n : Nonce), 
    ChaCha_digest (fst (ChaCha_update m (ChaCha_init k c n))) = ChaCha_Encrypt k c n m.


Axiom update_empty_state :
  forall (s : State),
    fst (ChaCha_update empty_string s) = s.

(* --- useful lemma about fold_right and concat (you already had it) --- *)
Lemma fold_right_concat : forall s l,
    fold_right concat s l = concat (fold_right concat empty_string l) s.
Proof.
  intros s l.
  induction l as [| x xs IH].
  - simpl. rewrite concat_empty_l. reflexivity.
  - simpl. rewrite IH. rewrite concat_assoc. reflexivity.
Qed.

(* --- auxiliary simple rev cons lemma (works by simpl) --- *)
(* helper: move fst out of a let '(a,_) := p in f a *)
Lemma fst_let_f : forall (A B:Type) (p : A * B) (f : A -> A * B),
  fst (let '(a, _) := p in f a) = fst (f (fst p)).
Proof.
  intros A B p f. destruct p as [a b]. simpl. reflexivity.
Qed.



Lemma let_out : forall (A B C : Type) (p : A * B) (g : A -> C),
  (let '(a, _) := p in g a) = g (fst p).
Proof.
  intros A B C [a b] g. simpl. reflexivity.
Qed.

Lemma update_concat_any :
  forall (l : list Msg) (s : State),
    fst (ChaCha_update (fold_right concat empty_string (rev l)) s) =
    fold_right (fun m st => fst (ChaCha_update m st)) s l.
Proof.
  induction l as [| x xs IH]; intros s.
  - simpl. apply update_empty_state.
  - simpl.
    (* fold_right concat empty_string (rev xs ++ [x]) = fold_right concat (fold_right concat empty_string [x]) (rev xs) *)
    rewrite fold_right_app.
    simpl. (* fold_right concat empty_string [x] -> concat x empty_string *)
    rewrite concat_empty. (* concat x empty_string = x *)
    rewrite fold_right_concat.
    (* Now we have goal: fst (ChaCha_update (concat (fold_right ...) x) s) = ... *)
    pose proof (update_concat (fold_right concat empty_string (rev xs)) x s) as Hupd.
    (* get equality of fsts *)
    apply (f_equal fst) in Hupd.
    (* rewrite the let-based RHS fst into fst (ChaCha_update x (fst (ChaCha_update ...))) *)
    rewrite (fst_let_f _ _ (ChaCha_update (fold_right concat empty_string (rev xs)) s)
                      (fun a => ChaCha_update x a)) in Hupd.
    (* now replace the inner fst using IH *)
    rewrite IH in Hupd.
    exact Hupd.
Qed.


Theorem ChaCha_incremental_equiv :
  forall (ms : list Msg) (k : Key) (c : Count) (n : Nonce),
    ChaCha_Encrypt k c n (fold_right concat empty_string  ms) =
    ChaCha_digest
      (fold_left (fun st m => fst (ChaCha_update m st))
                 ms (ChaCha_init k c n)).
Proof.
  intros.
  rewrite <- fold_left_rev_right in *.
  remember (rev ms).
  destruct l; simpl.
  - rewrite <- equiv_one. destruct ms.
  + simpl. rewrite update_empty_state. auto.
  +  assert (rev nil = rev (rev (m :: ms))). f_equal. auto.
       clear Heql. rewrite rev_involutive in *. simpl in *. congruence.
  - rewrite <- equiv_one. rewrite <- update_concat_any.
    f_equal.  assert (rev (m :: l) = rev (rev ms)). f_equal. auto.
    rewrite rev_involutive in *. subst. clear Heql. simpl.
    rewrite fold_right_app. simpl. rewrite concat_empty. rewrite fold_right_concat. auto.
  rewrite update_concat.
  rewrite (fst_let_f _ _ (ChaCha_update (fold_right concat empty_string (rev l)) (ChaCha_init k c n))
                   (fun a => ChaCha_update m a)).
  reflexivity.
Qed.


























