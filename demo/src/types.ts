export interface User {
  id: string;
  name: string;
  mail: string;
  password: string;
  type: string;
}

//supplier howa li ymanagi shit
//delivery ychof deliveries
//customer ychof his
//admin ymanager

export interface Log {
  id: string;
  message: string;
  type: "info" | "warning" | "error" | "success";
  timestamp: string; // ISO format
  userId?: string; // optional, could be linked to User
}

export interface CustomerProfile {
  id: number;
  user_id: number;
  date_of_birth?: string;
  gender?: "male" | "female" | "other";
  national_id?: string;
  profession?: string;
  medical_license?: string;
  organization_name?: string;
  organization_type?: "hospital" | "clinic" | "pharmacy" | "individual";
}

export type wilayaNamesEn =
  | "Adrar"
  | "Chlef"
  | "Laghouat"
  | "Oum El Bouaghi"
  | "Batna"
  | "Bejaia"
  | "Biskra"
  | "Bechar"
  | "Blida"
  | "Bouira"
  | "Tamanrasset"
  | "Tebessa"
  | "Tlemcen"
  | "Tiaret"
  | "Tizi Ouzou"
  | "Algiers"
  | "Djelfa"
  | "Jijel"
  | "Setif"
  | "Saida"
  | "Skikda"
  | "Sidi Bel Abbes"
  | "Annaba"
  | "Guelma"
  | "Constantine"
  | "Medea"
  | "Mostaganem"
  | "M'Sila"
  | "Mascara"
  | "Ouargla"
  | "Oran"
  | "El Bayadh"
  | "Illizi"
  | "Bordj Bou Arreridj"
  | "Boumerdes"
  | "El Tarf"
  | "Tindouf"
  | "Tissemsilt"
  | "El Oued"
  | "Khenchela"
  | "Souk Ahras"
  | "Tipaza"
  | "Mila"
  | "Ain Defla"
  | "Naama"
  | "Ain Temouchent"
  | "Ghardaia"
  | "Relizane";

export interface SupplierProfile {
  id: number;
  user_id: number;
  company_name: string;
  company_registration: string;
  tax_number: string;
  medical_license?: string;
  business_type?: "manufacturer" | "distributor" | "retailer" | "importer";
  verification_status?: "pending" | "approved" | "rejected";
  verification_documents?: Record<string, object> | null;
  annual_revenue?: number;
  established_year?: number;
  employee_count?: number;
  warehouse_capacity?: number;
  subscription_type?: "basic" | "premium" | "enterprise";
  subscription_expires_at?: string;
  commission_rate?: number;
  created_at?: string;
  updated_at?: string;
}

export // Product Interface
interface Product {
  id: number;
  supplier_id: number;
  category_id: number;
  brand_id?: number;
  sku: string;
  barcode?: string;
  name_en: string;
  description_ar?: string;
  description_fr?: string;
  description_en?: string;
  short_description_ar?: string;
  short_description_fr?: string;
  short_description_en?: string;
  specifications?: Record<string, object> | null;
  ingredients?: string;
  usage_instructions_ar?: string;
  usage_instructions_fr?: string;
  usage_instructions_en?: string;
  warnings_ar?: string;
  warnings_fr?: string;
  warnings_en?: string;
  requires_prescription?: boolean;
  prescription_type?: "none" | "otc" | "prescription" | "controlled";
  age_restriction?: number;
  weight?: number;
  dimensions?: string;
  material?: string;
  sterile?: boolean;
  disposable?: boolean;
  expiry_tracking?: boolean;
  batch_tracking?: boolean;
  status?: "draft" | "pending" | "active" | "inactive" | "discontinued";
  approval_status?: "pending" | "approved" | "rejected";
  rejection_reason?: string;
  meta_title?: string;
  meta_description?: string;
  meta_keywords?: string;
  slug?: string;
  featured?: boolean;
  created_at?: string;
  updated_at?: string;
  price: number;
  image: string;
}

export interface Delivery {
  id: number | string;
  order_id: number | string;
  customer_name: string;
  destination: string;
  status: "pending" | "in-progress" | "delivered";
  payment_status: "paid" | "unpaid";
  assigned_to?: number; // user ID of delivery person
}

export interface BaseProfile {
  id: number;
  user_id: number | string;
  date_of_birth: string;
  gender: "male" | "female" | "other";
  national_id: string;
}

// Delivery-specific
export interface DeliveryProfile extends BaseProfile {
  vehicle_type: string;
  license_plate: string;
}

// Supplier-specific
export interface SupplierProfile extends BaseProfile {
  company_name: string;
  business_license: string;
}
