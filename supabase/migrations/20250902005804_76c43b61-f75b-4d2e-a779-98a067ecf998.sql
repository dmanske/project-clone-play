-- =====================================================
-- CONFIGURAR STORAGE BUCKETS
-- =====================================================

-- Bucket para fotos de clientes
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'client-photos',
  'client-photos',
  true,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Bucket para logos da empresa
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'logos',
  'logos',
  true,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
) ON CONFLICT (id) DO NOTHING;

-- Bucket para imagens de ônibus
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'onibus',
  'onibus',
  true,
  10485760, -- 10MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- POLÍTICAS DE STORAGE
-- =====================================================

-- Políticas para client-photos
CREATE POLICY "Fotos de clientes são públicas"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'client-photos');

CREATE POLICY "Público pode fazer upload de fotos de clientes"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'client-photos');

CREATE POLICY "Admin pode gerenciar fotos de clientes"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'client-photos')
WITH CHECK (bucket_id = 'client-photos');

-- Políticas para logos
CREATE POLICY "Logos são públicos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'logos');

CREATE POLICY "Público pode fazer upload de logos"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'logos');

CREATE POLICY "Admin pode gerenciar logos"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'logos')
WITH CHECK (bucket_id = 'logos');

-- Políticas para onibus
CREATE POLICY "Imagens de ônibus são públicas"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'onibus');

CREATE POLICY "Admin pode gerenciar imagens de ônibus"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'onibus')
WITH CHECK (bucket_id = 'onibus');