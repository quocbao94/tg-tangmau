-- Tracking MEP tầng mẫu – schema cho Supabase
-- Chạy toàn bộ file này trong Supabase Dashboard → SQL Editor.

create table if not exists areas (
  code  text primary key,          -- 'can_ho' | 'hanh_lang'
  name  text not null,
  sort  int  not null
);

create table if not exists locations (     -- CH 01…, ZONE 1…
  id        bigint generated always as identity primary key,
  area_code text not null references areas(code),
  name      text not null,
  sort      int  not null,
  unique (area_code, name)
);

create table if not exists tasks (         -- các dòng công việc
  id         bigint generated always as identity primary key,
  area_code  text not null references areas(code),
  stt        int  not null,
  stage      text not null,                -- giai đoạn: TRƯỚC XÂY TƯỜNG…
  discipline text not null check (discipline in ('dien','ctn','dhkk','pccc','chung')),
  name       text not null,
  seq        int,                          -- trình tự thi công
  unique (area_code, stt)
);

create table if not exists progress (      -- trạng thái từng ô
  task_id     bigint not null references tasks(id) on delete cascade,
  location_id bigint not null references locations(id) on delete cascade,
  status      text   not null check (status in ('wip','done')),
  deadline    date,                       -- hạn hoàn thành khi đang thi công
  pct         smallint check (pct between 0 and 100), -- % hoàn thành khi đang thi công
  note        text,
  updated_at  timestamptz not null default now(),
  primary key (task_id, location_id)
);
-- Ô không có dòng trong progress = chưa triển khai.

-- Quyền: ai có link cũng xem và sửa được trạng thái (bảng progress).
-- Danh sách khu vực, vị trí, công việc chỉ đọc từ web.
alter table areas     enable row level security;
alter table locations enable row level security;
alter table tasks     enable row level security;
alter table progress  enable row level security;

create policy "read areas"     on areas     for select using (true);
create policy "read locations" on locations for select using (true);
create policy "read tasks"     on tasks     for select using (true);
create policy "read progress"  on progress  for select using (true);
create policy "write progress" on progress  for all to anon, authenticated using (true) with check (true);

-- ===== Dữ liệu ban đầu (lấy từ index.html) =====
insert into areas (code,name,sort) values
  ('can_ho','Căn hộ',1),
  ('hanh_lang','Hành lang',2)
on conflict do nothing;

insert into locations (area_code,name,sort) values
  ('can_ho','CH 01',1),
  ('can_ho','CH 02',2),
  ('can_ho','CH 03',3),
  ('can_ho','CH 04',4),
  ('can_ho','CH 05',5),
  ('can_ho','CH 06',6),
  ('can_ho','CH 07',7),
  ('can_ho','CH 08',8),
  ('can_ho','CH 09',9),
  ('can_ho','CH 10',10),
  ('can_ho','CH 11',11),
  ('can_ho','CH 12',12),
  ('can_ho','CH 13',13),
  ('can_ho','CH 14',14),
  ('can_ho','CH 15',15),
  ('can_ho','CH 16',16),
  ('can_ho','CH 17',17),
  ('can_ho','CH 18',18),
  ('can_ho','CH 39',19),
  ('can_ho','CH 40',20),
  ('can_ho','CH 41',21),
  ('can_ho','CH 42',22),
  ('can_ho','CH 43',23),
  ('hanh_lang','ZONE 1',1),
  ('hanh_lang','ZONE 2',2),
  ('hanh_lang','ZONE 3',3)
on conflict do nothing;

insert into tasks (area_code,stt,stage,discipline,name,seq) values
  ('can_ho',1,'TRƯỚC XÂY TƯỜNG','dien','Thông dây, xử lý nghẹt ống điện',1),
  ('can_ho',2,'TRƯỚC XÂY TƯỜNG','dien','Lắp đặt nối ống điện kicker sàn âm',2),
  ('can_ho',3,'TRƯỚC XÂY TƯỜNG','ctn','Hoàn công sleeve ống CTN và xử lý sai lệch',1),
  ('can_ho',4,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt trục đứng nước thoát căn hộ',1),
  ('can_ho',5,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt layout nước thoát',2),
  ('can_ho',6,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt layout nước cấp căn hộ',3),
  ('can_ho',7,'TRƯỚC XÂY TƯỜNG','ctn','Test hệ thống ống thoát căn hộ',3),
  ('can_ho',8,'TRƯỚC XÂY TƯỜNG','dhkk','Lắp đặt trục đứng nước ngưng',1),
  ('can_ho',9,'TRƯỚC XÂY TƯỜNG','dhkk','Lắp đặt ống nước ngưng trong căn hộ',2),
  ('can_ho',10,'TRƯỚC XÂY TƯỜNG','pccc','Lắp đặt ống chữa cháy căn hộ',2),
  ('can_ho',11,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống hút bếp, hút toilet căn hộ',3),
  ('can_ho',12,'SAU XÂY TƯỜNG','chung','Marking toàn bộ Mep âm tường',4),
  ('can_ho',13,'SAU XÂY TƯỜNG','chung','Cắt, đục tường toàn bộ Mep âm tường',5),
  ('can_ho',14,'SAU XÂY TƯỜNG','dien','Hoàn công ống âm, đế âm vách bê tông',6),
  ('can_ho',15,'SAU XÂY TƯỜNG','dien','Lắp đặt ống/Box điện âm tường',6),
  ('can_ho',16,'SAU XÂY TƯỜNG','ctn','Lắp đặt ống cấp nước âm tường',6),
  ('can_ho',17,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống đồng âm tường và Layout',6),
  ('can_ho',18,'SAU TÔ TƯỜNG','dien','Kéo cáp điện/điện nhẹ căn hộ',7),
  ('can_ho',19,'SAU TÔ TƯỜNG','dien','Test cáp điện/điện nhẹ căn hộ',8),
  ('can_ho',20,'SAU TÔ TƯỜNG','ctn','Test hệ thống ống cấp căn hộ',7),
  ('can_ho',21,'SAU TÔ TƯỜNG','pccc','Kéo cáp báo cháy căn hộ',7),
  ('can_ho',22,'SAU TÔ TƯỜNG','pccc','Test cáp báo cháy căn hộ',8),
  ('can_ho',23,'SAU TÔ TƯỜNG','pccc','Test ống chữa cháy căn hộ',7),
  ('can_ho',24,'SAU TÔ TƯỜNG','ctn','Lắp đặt trục thoát nước logia',8),
  ('hanh_lang',1,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt nước cấp hành lang',1),
  ('hanh_lang',2,'SAU XÂY TƯỜNG','pccc','Ống chữa cháy hành lang',2),
  ('hanh_lang',3,'SAU XÂY TƯỜNG','dien','Lắp đặt máng cáp hành lang',3),
  ('hanh_lang',4,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống gió/Van gió layout hành lang',4),
  ('hanh_lang',5,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống gió trục đứng hành lang',5),
  ('hanh_lang',6,'SAU XÂY TƯỜNG','dhkk','Test ống gió trục đứng hành lang',6),
  ('hanh_lang',7,'SAU XÂY TƯỜNG','pccc','Lắp đặt ống/box báo cháy âm tường hành lang',5),
  ('hanh_lang',8,'SAU TÔ TƯỜNG','dien','Kéo cáp điện/điện nhẹ hành lang',7),
  ('hanh_lang',9,'SAU TÔ TƯỜNG','dien','Test cáp điện/điện nhẹ hành lang',8),
  ('hanh_lang',10,'SAU TÔ TƯỜNG','pccc','Kéo cáp báo cháy hành lang',7),
  ('hanh_lang',11,'SAU TÔ TƯỜNG','pccc','Test cáp báo cháy hành lang',8),
  ('hanh_lang',12,'SAU TÔ TƯỜNG','pccc','Lắp đặt tủ chữa cháy hành lang',8),
  ('hanh_lang',13,'SAU TÔ TƯỜNG','ctn','Test ống cấp hành lang',8),
  ('hanh_lang',14,'SAU TÔ TƯỜNG','dhkk','Test ống gió layout hành lang',8),
  ('hanh_lang',15,'SAU SƠN LỚP 1','dien','PKT điện: Lắp đặt thang máng cáp',9),
  ('hanh_lang',16,'SAU SƠN LỚP 1','dien','PKT điện: Lắp đặt tủ điện',9),
  ('hanh_lang',17,'SAU SƠN LỚP 1','ctn','PKT nước: Lắp đặt module cụm đồng hồ nước',9),
  ('hanh_lang',18,'SAU SƠN LỚP 1','pccc','PKT nước: Lắp đặt trục ống chữa cháy trong PKT',9),
  ('hanh_lang',19,'SAU SƠN LỚP 1','dhkk','PKT điện: Lắp đặt trục ống gió',9),
  ('hanh_lang',20,'SAU SƠN LỚP 1','dhkk','Phòng rác: Lắp đặt trục ống gió hút mùi',9)
on conflict do nothing;

-- Realtime: trang web tự cập nhật khi người khác đổi trạng thái.
alter publication supabase_realtime add table progress;
alter table progress replica identity full;

-- Cho phép sửa trình tự từ web (chỉ cột seq của tasks)
revoke update on tasks from anon, authenticated;
grant update (seq) on tasks to anon, authenticated;
create policy "edit seq" on tasks for update to anon, authenticated using (true) with check (true);
alter publication supabase_realtime add table tasks;

-- ===== XD bàn giao =====
create table if not exists milestones (     -- các mốc bàn giao của XD
  id    bigint generated always as identity primary key,
  name  text not null unique,
  sort  int  not null
);
create table if not exists handovers (      -- ngày nhận bàn giao theo từng vị trí
  milestone_id bigint not null references milestones(id) on delete cascade,
  location_id  bigint not null references locations(id) on delete cascade,
  date         date   not null,
  updated_at   timestamptz not null default now(),
  primary key (milestone_id, location_id)
);
alter table milestones enable row level security;
alter table handovers  enable row level security;
create policy "read milestones" on milestones for select using (true);
create policy "read handovers"  on handovers  for select using (true);
create policy "write handovers" on handovers  for all to anon, authenticated using (true) with check (true);
alter publication supabase_realtime add table handovers;
alter table handovers replica identity full;
insert into milestones (name,sort) values ('Bàn giao mặt bằng',1) on conflict do nothing;

-- Mốc tính mặc định từ mốc khác: ngày mặc định = ngày của base_id + offset_days (sửa tay thì lưu vào handovers)
alter table milestones add column if not exists base_id bigint references milestones(id);
alter table milestones add column if not exists offset_days int;
insert into milestones (name,sort,base_id,offset_days)
select 'Bàn giao tường xây',2,id,14 from milestones where name='Bàn giao mặt bằng'
on conflict (name) do nothing;

-- Vị trí dòng mốc trong bảng: null = đầu bảng, có giá trị = ngay trước giai đoạn đó
alter table milestones add column if not exists before_stage text;
update milestones set before_stage='SAU XÂY TƯỜNG' where name='Bàn giao tường xây';

insert into milestones (name,sort,base_id,offset_days,before_stage)
select 'Bàn giao tô tường',3,id,14,'SAU TÔ TƯỜNG' from milestones where name='Bàn giao tường xây'
on conflict (name) do nothing;

-- Dòng "Vị trí" hiển thị dưới tiêu đề và trên file PDF
alter table areas add column if not exists location_label text;
update areas set location_label='TẦNG MẪU – TẦNG 5 THÁP B (23 căn: CH 01–18, CH 39–43)' where code='can_ho';
update areas set location_label='TẦNG MẪU – TẦNG 5 THÁP B – HÀNH LANG' where code='hanh_lang';

-- Hành lang thêm ZONE 4
insert into locations (area_code,name,sort) values ('hanh_lang','ZONE 4',4) on conflict do nothing;
-- Mốc chỉ áp dụng cho một khu vực (null = mọi khu vực)
alter table milestones add column if not exists area_code text references areas(code);
insert into milestones (name,sort,before_stage,area_code)
values ('Bàn giao sơn lớp 1',4,'SAU SƠN LỚP 1','hanh_lang') on conflict (name) do nothing;

-- Nhóm căn hộ theo zone
alter table locations add column if not exists zone text;
update locations l set zone=v.z from (values
  ('ZONE 1',array['CH 02','CH 03','CH 04','CH 05','CH 06','CH 07','CH 08']),
  ('ZONE 2',array['CH 01','CH 09','CH 10','CH 11']),
  ('ZONE 3',array['CH 12','CH 13','CH 14','CH 43']),
  ('ZONE 4',array['CH 15','CH 16','CH 17','CH 18','CH 39','CH 40','CH 41','CH 42'])
) v(z,names) where l.area_code='can_ho' and l.name=any(v.names);
