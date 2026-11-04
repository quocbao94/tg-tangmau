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
  unique (area_code, stt)
);

create table if not exists progress (      -- trạng thái từng ô
  task_id     bigint not null references tasks(id) on delete cascade,
  location_id bigint not null references locations(id) on delete cascade,
  status      text   not null check (status in ('wip','done')),
  note        text,
  updated_at  timestamptz not null default now(),
  updated_by  uuid default auth.uid(),
  primary key (task_id, location_id)
);
-- Ô không có dòng trong progress = chưa triển khai.

-- Quyền: ai cũng xem được, chỉ người đăng nhập mới được sửa trạng thái.
alter table areas     enable row level security;
alter table locations enable row level security;
alter table tasks     enable row level security;
alter table progress  enable row level security;

create policy "read areas"     on areas     for select using (true);
create policy "read locations" on locations for select using (true);
create policy "read tasks"     on tasks     for select using (true);
create policy "read progress"  on progress  for select using (true);
create policy "write progress" on progress  for all to authenticated using (true) with check (true);

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

insert into tasks (area_code,stt,stage,discipline,name) values
  ('can_ho',1,'TRƯỚC XÂY TƯỜNG','dien','Thông dây, xử lý nghẹt ống điện'),
  ('can_ho',2,'TRƯỚC XÂY TƯỜNG','dien','Hoàn công ống âm, đế âm vách bê tông'),
  ('can_ho',3,'TRƯỚC XÂY TƯỜNG','dien','Lắp đặt nối ống điện kicker sàn âm'),
  ('can_ho',4,'TRƯỚC XÂY TƯỜNG','ctn','Hoàn công sleeve ống CTN và xử lý sai lệch'),
  ('can_ho',5,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt trục đứng nước thoát căn hộ'),
  ('can_ho',6,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt layout nước thoát'),
  ('can_ho',7,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt layout nước cấp căn hộ'),
  ('can_ho',8,'TRƯỚC XÂY TƯỜNG','ctn','Test hệ thống ống thoát căn hộ'),
  ('can_ho',9,'TRƯỚC XÂY TƯỜNG','dhkk','Lắp đặt trục đứng nước ngưng'),
  ('can_ho',10,'TRƯỚC XÂY TƯỜNG','dhkk','Lắp đặt ống nước ngưng trong căn hộ'),
  ('can_ho',11,'TRƯỚC XÂY TƯỜNG','dhkk','Lắp đặt ống hút bếp, hút toilet căn hộ'),
  ('can_ho',12,'TRƯỚC XÂY TƯỜNG','pccc','Lắp đặt ống chữa cháy căn hộ'),
  ('can_ho',13,'SAU XÂY TƯỜNG','chung','Marking toàn bộ Mep âm tường'),
  ('can_ho',14,'SAU XÂY TƯỜNG','chung','Cắt, đục tường toàn bộ Mep âm tường'),
  ('can_ho',15,'SAU XÂY TƯỜNG','dien','Lắp đặt ống/Box điện âm tường'),
  ('can_ho',16,'SAU XÂY TƯỜNG','ctn','Lắp đặt ống cấp nước âm tường'),
  ('can_ho',17,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống đồng âm tường và Layout'),
  ('can_ho',18,'SAU TÔ TƯỜNG','dien','Kéo cáp điện/điện nhẹ căn hộ'),
  ('can_ho',19,'SAU TÔ TƯỜNG','dien','Test cáp điện/điện nhẹ căn hộ'),
  ('can_ho',20,'SAU TÔ TƯỜNG','ctn','Test hệ thống ống cấp căn hộ'),
  ('can_ho',21,'SAU TÔ TƯỜNG','pccc','Kéo cáp báo cháy căn hộ'),
  ('can_ho',22,'SAU TÔ TƯỜNG','pccc','Test cáp báo cháy căn hộ'),
  ('can_ho',23,'SAU TÔ TƯỜNG','pccc','Test ống chữa cháy căn hộ'),
  ('can_ho',24,'SAU TÔ TƯỜNG','ctn','Lắp đặt trục thoát nước logia'),
  ('hanh_lang',1,'TRƯỚC XÂY TƯỜNG','ctn','Lắp đặt nước cấp hành lang'),
  ('hanh_lang',2,'TRƯỚC XÂY TƯỜNG','pccc','Ống chữa cháy hành lang'),
  ('hanh_lang',3,'TRƯỚC XÂY TƯỜNG','dien','Lắp đặt máng cáp hành lang'),
  ('hanh_lang',4,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống gió/Van gió layout hành lang'),
  ('hanh_lang',5,'SAU XÂY TƯỜNG','dhkk','Lắp đặt ống gió trục đứng hành lang'),
  ('hanh_lang',6,'SAU XÂY TƯỜNG','dhkk','Test ống gió trục đứng hành lang'),
  ('hanh_lang',7,'SAU XÂY TƯỜNG','pccc','Lắp đặt tủ chữa cháy hành lang'),
  ('hanh_lang',8,'SAU XÂY TƯỜNG','pccc','Lắp đặt ống/box báo cháy âm tường hành lang'),
  ('hanh_lang',9,'SAU TÔ TƯỜNG','dien','Kéo cáp điện/điện nhẹ hành lang'),
  ('hanh_lang',10,'SAU TÔ TƯỜNG','dien','Test cáp điện/điện nhẹ hành lang'),
  ('hanh_lang',11,'SAU TÔ TƯỜNG','pccc','Kéo cáp báo cháy hành lang'),
  ('hanh_lang',12,'SAU TÔ TƯỜNG','pccc','Test cáp báo cháy hành lang'),
  ('hanh_lang',13,'SAU TÔ TƯỜNG','ctn','Test ống cấp hành lang'),
  ('hanh_lang',14,'SAU TÔ TƯỜNG','dhkk','Test ống gió layout hành lang'),
  ('hanh_lang',15,'SAU SƠN LỚP 1','dien','PKT điện: Lắp đặt thang máng cáp'),
  ('hanh_lang',16,'SAU SƠN LỚP 1','dien','PKT điện: Lắp đặt tủ điện'),
  ('hanh_lang',17,'SAU SƠN LỚP 1','ctn','PKT nước: Lắp đặt module cụm đồng hồ nước'),
  ('hanh_lang',18,'SAU SƠN LỚP 1','pccc','PKT nước: Lắp đặt trục ống chữa cháy trong PKT'),
  ('hanh_lang',19,'SAU SƠN LỚP 1','dhkk','PKT điện: Lắp đặt trục ống gió'),
  ('hanh_lang',20,'SAU SƠN LỚP 1','dhkk','Phòng rác: Lắp đặt trục ống gió hút mùi')
on conflict do nothing;
