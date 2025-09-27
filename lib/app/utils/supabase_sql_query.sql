-- ENUMS
CREATE TYPE user_role AS ENUM ('customer', 'shop_owner', 'admin');
CREATE TYPE shop_status AS ENUM ('pending', 'active', 'suspended');
CREATE TYPE subscription_plan AS ENUM ('basic', 'standard', 'premium');
CREATE TYPE subscription_status AS ENUM ('active', 'expired', 'suspended');
CREATE TYPE message_type AS ENUM ('text', 'image', 'product');

-- USERS
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  role user_role NOT NULL DEFAULT 'customer',
  cnic TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- PLAZAS
CREATE TABLE IF NOT EXISTS public.plazas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  city TEXT,
  address TEXT,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SHOPS
CREATE TABLE IF NOT EXISTS public.shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  shop_name TEXT NOT NULL,
  plaza_id UUID NOT NULL REFERENCES public.plazas(id) ON DELETE CASCADE,
  address TEXT,
  description TEXT,
  logo_url TEXT,
  phone TEXT,
  status shop_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  plan_type subscription_plan NOT NULL DEFAULT 'basic',
  listing_limit INT NOT NULL DEFAULT 10,
  status subscription_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  category TEXT NOT NULL,
  image_urls TEXT[] DEFAULT '{}',
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- FAVORITES
CREATE TABLE IF NOT EXISTS public.favorites (
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, product_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_unique_user_product
ON public.favorites(user_id, product_id);

-- CHATS
CREATE TABLE IF NOT EXISTS public.chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  shop_owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id),
  unread_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- MESSAGES
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message_text TEXT,
  type message_type NOT NULL DEFAULT 'text',
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  product_id UUID REFERENCES public.products(id),
  shop_id UUID REFERENCES public.shops(id)
);

-- PAYMENT PROOFS
CREATE TABLE IF NOT EXISTS public.payment_proofs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  proof_image_url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_shops_owner ON public.shops(owner_id);
CREATE INDEX IF NOT EXISTS idx_shops_plaza ON public.shops(plaza_id);
CREATE INDEX IF NOT EXISTS idx_products_shop ON public.products(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON public.products(is_active);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_chats_customer ON public.chats(customer_id);
CREATE INDEX IF NOT EXISTS idx_chats_shop_owner ON public.chats(shop_owner_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat ON public.messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON public.messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_read ON public.messages(receiver_id, is_read);
CREATE INDEX IF NOT EXISTS idx_payment_proofs_shop ON public.payment_proofs(shop_id);

-- RLS
ALTER TABLE public.plazas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_proofs ENABLE ROW LEVEL SECURITY;

-- POLICIES
CREATE POLICY users_select_self ON public.users
  FOR SELECT USING (id = auth.uid());
CREATE POLICY users_update_self ON public.users
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY products_public_read ON public.products
  FOR SELECT USING (is_active = TRUE OR shop_id IN (SELECT id FROM public.shops WHERE owner_id = auth.uid()));
CREATE POLICY products_owner_manage ON public.products
  FOR ALL USING (shop_id IN (SELECT id FROM public.shops WHERE owner_id = auth.uid()));

CREATE POLICY chats_participants_manage ON public.chats
  FOR ALL USING (customer_id = auth.uid() OR shop_owner_id = auth.uid());

CREATE POLICY messages_participants_manage ON public.messages
  FOR ALL USING (sender_id = auth.uid() OR receiver_id = auth.uid());

CREATE POLICY favorites_user_manage ON public.favorites
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY payment_proofs_owner ON public.payment_proofs
  FOR SELECT USING (shop_id IN (SELECT id FROM public.shops WHERE owner_id = auth.uid()));

-- REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chats;
ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
ALTER PUBLICATION supabase_realtime ADD TABLE public.shops;

-- TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGERS
CREATE TRIGGER set_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

CREATE TRIGGER set_shops_updated_at
BEFORE UPDATE ON public.shops
FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

CREATE TRIGGER set_products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

CREATE TRIGGER set_chats_updated_at
BEFORE UPDATE ON public.chats
FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

CREATE TRIGGER set_messages_updated_at
BEFORE UPDATE ON public.messages
FOR EACH ROW EXECUTE PROCEDURE set_updated_at();


-- USERS
CREATE POLICY "Allow logged-in users full access"
ON public.users
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- PLAZAS
CREATE POLICY "Allow logged-in users full access"
ON public.plazas
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- SHOPS
CREATE POLICY "Allow logged-in users full access"
ON public.shops
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- SUBSCRIPTIONS
CREATE POLICY "Allow logged-in users full access"
ON public.subscriptions
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- PRODUCTS
CREATE POLICY "Allow logged-in users full access"
ON public.products
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- FAVORITES
CREATE POLICY "Allow logged-in users full access"
ON public.favorites
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- CHATS
CREATE POLICY "Allow logged-in users full access"
ON public.chats
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- MESSAGES
CREATE POLICY "Allow logged-in users full access"
ON public.messages
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- PAYMENT PROOFS
CREATE POLICY "Allow logged-in users full access"
ON public.payment_proofs
FOR ALL
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);
