drop policy "Allow authenticated insert access" on "public"."pairs";

drop policy "Allow authenticated read access" on "public"."pairs";

drop policy "Allow authenticated update access" on "public"."pairs";

drop policy "Allow authenticated insert access" on "public"."strategies";

drop policy "Allow authenticated read access" on "public"."strategies";

drop policy "Allow authenticated update access" on "public"."strategies";

alter table "public"."pairs" drop constraint "pairs_name_key";

alter table "public"."strategies" drop constraint "strategies_name_key";

drop index if exists "public"."pairs_name_key";

drop index if exists "public"."strategies_name_key";

alter table "public"."pairs" add column "user_id" uuid not null default auth.uid();

alter table "public"."strategies" add column "user_id" uuid not null default auth.uid();

CREATE UNIQUE INDEX pairs_user_id_name_key ON public.pairs USING btree (user_id, name);

CREATE UNIQUE INDEX strategies_user_id_name_key ON public.strategies USING btree (user_id, name);

alter table "public"."pairs" add constraint "pairs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."pairs" validate constraint "pairs_user_id_fkey";

alter table "public"."pairs" add constraint "pairs_user_id_name_key" UNIQUE using index "pairs_user_id_name_key";

alter table "public"."strategies" add constraint "strategies_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."strategies" validate constraint "strategies_user_id_fkey";

alter table "public"."strategies" add constraint "strategies_user_id_name_key" UNIQUE using index "strategies_user_id_name_key";

create policy "Users can delete their own pairs"
on "public"."pairs"
as permissive
for delete
to authenticated
using ((auth.uid() = user_id));


create policy "Users can insert their own pairs"
on "public"."pairs"
as permissive
for insert
to authenticated
with check ((auth.uid() = user_id));


create policy "Users can select their own pairs"
on "public"."pairs"
as permissive
for select
to authenticated
using ((auth.uid() = user_id));


create policy "Users can update their own pairs"
on "public"."pairs"
as permissive
for update
to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));


create policy "Users can delete their own strategies"
on "public"."strategies"
as permissive
for delete
to authenticated
using ((auth.uid() = user_id));


create policy "Users can insert their own strategies"
on "public"."strategies"
as permissive
for insert
to authenticated
with check ((auth.uid() = user_id));


create policy "Users can select their own strategies"
on "public"."strategies"
as permissive
for select
to authenticated
using ((auth.uid() = user_id));


create policy "Users can update their own strategies"
on "public"."strategies"
as permissive
for update
to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



