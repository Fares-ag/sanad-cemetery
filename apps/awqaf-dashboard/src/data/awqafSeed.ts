import type { AuditEntry, AwqafCase, GhuslTask, GuidanceRequest, JanazahEntry } from '../types';

const now = Date.now();

export const SEED_JANAZAH: JanazahEntry[] = [
  {
    id: 'JZ-001',
    deceasedName: 'Khalid Al-Mansouri',
    deceasedNameAr: 'خالد المنصوري',
    mosqueName: 'Imam Muhammad ibn Abdul Wahhab Mosque',
    mosqueNameAr: 'مسجد الإمام محمد بن عبد الوهاب',
    prayerAt: new Date(now + 3600000 * 5).toISOString(),
    status: 'scheduled',
    notes: 'Family notified — coordinate with municipality burial slot.',
    notesAr: 'تم إشعار العائلة — التنسيق مع البلدية لموعد الدفن.',
  },
  {
    id: 'JZ-002',
    deceasedName: 'Fatima Hassan',
    deceasedNameAr: 'فاطمة حسن',
    mosqueName: 'Education City Mosque',
    mosqueNameAr: 'مسجد المدينة التعليمية',
    prayerAt: new Date(now - 3600000 * 2).toISOString(),
    status: 'completed',
  },
  {
    id: 'JZ-003',
    deceasedName: 'Ahmad Al-Thani',
    deceasedNameAr: 'أحمد آل ثاني',
    mosqueName: 'Al Rayyan central mosque',
    mosqueNameAr: 'مسجد الريان المركزي',
    prayerAt: new Date(now + 3600000 * 28).toISOString(),
    status: 'delayed',
    notes: 'Awaiting overseas next of kin.',
    notesAr: 'بانتظار وريث من الخارج.',
  },
];

export const SEED_GHUSL: GhuslTask[] = [
  {
    id: 'GH-101',
    deceasedName: 'Khalid Al-Mansouri',
    deceasedNameAr: 'خالد المنصوري',
    facilityName: 'Al Rayyan ghusl facility',
    facilityNameAr: 'مرفق غسل الريان',
    scheduledAt: new Date(now + 3600000 * 3).toISOString(),
    status: 'in_progress',
  },
  {
    id: 'GH-102',
    deceasedName: 'Omar Saleh',
    deceasedNameAr: 'عمر صالح',
    facilityName: 'Doha central washing facility',
    facilityNameAr: 'مرفق الغسل المركزي — الدوحة',
    scheduledAt: new Date(now + 3600000 * 18).toISOString(),
    status: 'pending',
  },
];

export const SEED_GUIDANCE: GuidanceRequest[] = [
  {
    id: 'GD-201',
    topic: 'Burial timing',
    topicAr: 'توقيت الدفن',
    summary: 'Family asks about delaying burial until relative arrives — Sharia considerations.',
    summaryAr: 'العائلة تسأل عن تأخير الدفن حتى وصول أحد الأقارب — اعتبارات شرعية.',
    status: 'assigned',
    createdAt: new Date(now - 86400000 * 2).toISOString(),
  },
  {
    id: 'GD-202',
    topic: 'Non-Muslim cemetery boundary',
    topicAr: 'حدود مقبرة غير المسلمين',
    summary: 'Clarification on visiting adjacent section — public message.',
    summaryAr: 'توضيح بشأن زيارة القسم المجاور — رسالة للجمهور.',
    status: 'new',
    createdAt: new Date(now - 3600000 * 8).toISOString(),
  },
];

export const SEED_COMPLIANCE: AwqafCase[] = [
  {
    id: 'AC-501',
    kind: 'complaint',
    summary: 'Visitor parking dispute — liaison with municipality',
    summaryAr: 'نزاع مواقف الزوار — تنسيق مع البلدية',
    status: 'in_review',
    cemeteryHint: 'Al Rayyan Cemetery',
    cemeteryHintAr: 'مقبرة الريان',
    createdAt: new Date(now - 86400000 * 3).toISOString(),
    updatedAt: new Date(now - 86400000).toISOString(),
  },
  {
    id: 'AC-502',
    kind: 'religious_fine',
    summary: 'Reported breach of cemetery hours policy',
    summaryAr: 'بلاغ بمخالفة ساعات عمل المقبرة',
    status: 'open',
    cemeteryHint: 'Al Wakrah Cemetery',
    cemeteryHintAr: 'مقبرة الوكرة',
    createdAt: new Date(now - 86400000).toISOString(),
  },
];

/** Awqaf-focused audit lines (demo). */
export const SEED_AWQAF_AUDIT: AuditEntry[] = [
  {
    id: 'AA-1',
    timestamp: new Date(now - 86400000).toISOString(),
    action: 'janazah_scheduled',
    actionAr: 'جدولة_جنازة',
    detail: 'JZ-001 prayer slot confirmed with imam on duty',
    detailAr: 'تأكيد موعد صلاة JZ-001 مع إمام المناوبة',
    actor: 'coordinator@awqaf.gov',
    actorAr: 'منسق@أوقاف.حكومة',
  },
  {
    id: 'AA-2',
    timestamp: new Date(now - 86400000 * 2).toISOString(),
    action: 'ghusl_started',
    actionAr: 'بدء_غسل',
    detail: 'GH-101 in progress — facility Al Rayyan',
    detailAr: 'GH-101 قيد التنفيذ — مرفق الريان',
    actor: 'facility_lead',
    actorAr: 'مسؤول_المرفق',
  },
  {
    id: 'AA-3',
    timestamp: new Date(now - 3600000 * 6).toISOString(),
    action: 'guidance_assigned',
    actionAr: 'إسناد_إرشاد',
    detail: 'GD-201 assigned to senior scholar (demo)',
    detailAr: 'إسناد GD-201 لعالم دين أقدم (عرض تجريبي)',
    actor: 'awqaf_ops',
    actorAr: 'عمليات_أوقاف',
  },
];
