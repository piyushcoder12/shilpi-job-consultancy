SHILPI JOB CONSULTANCY — BLOG ADMIN STARTER

इस पैकेज में:
- index.html: मौजूदा वेबसाइट; Blog section Supabase से Published blogs दिखाएगा।
- admin.html: Multiple Admin login, blog create/edit/draft/publish/delete।
- blog.html: पूरा blog article पढ़ने का page।
- supabase/schema.sql: Database tables, Row Level Security policies और image bucket।
- supabase-config.js: Supabase project URL और anon/public key के placeholders।

जरूरी: यह starter files हैं। Supabase project से connect और deploy अभी नहीं हुआ है।

SETUP STEPS
1) https://supabase.com पर free account बनाकर New project बनाएँ। Project URL और anon/public key Project Settings > API से लें।
2) Supabase SQL Editor खोलें और supabase/schema.sql की पूरी सामग्री run करें।
3) Authentication > Users में हर admin के लिए अलग-अलग Invite user करें। Public sign-ups enable न करें। हर व्यक्ति अपना अलग login/password इस्तेमाल करे।
4) हर invited user का UUID कॉपी करें। SQL Editor में सभी authorised admins को एक साथ add करें (UUID को असली UUID से बदलें):
   insert into public.admin_users(user_id, display_name) values
   ('FIRST-USER-UUID', 'Owner'),
   ('SECOND-USER-UUID', 'Content Admin');
   जरूरत के अनुसार और rows जोड़ें। एक व्यक्ति के लिए एक row रखें।
5) supabase-config.js में YOUR-PROJECT-ID और YOUR_SUPABASE_ANON_PUBLIC_KEY बदलें। केवल anon/public key लगाएँ। service_role key कभी browser files में न डालें।
6) इस folder की सभी files GitHub repository के root में upload/commit करें। Vercel deployment पूरा होने दें।
7) https://YOUR-SITE.vercel.app/admin.html खोलकर admin email/password से login करें। हर approved admin अपने account से login कर सकता है।
8) Blog लिखें, Draft save करें या Publish करें। Published blogs homepage पर दिखेंगे।

SECURITY NOTES
- RLS policies database पर permissions enforce करती हैं। केवल admin_users में दर्ज users को blog edit/publish/delete की अनुमति है। Multiple admins एक ही CMS इस्तेमाल कर सकते हैं।
- हर admin का अलग account रखें; password share न करें। किसी admin का access हटाने के लिए admin_users से उसकी row delete करें और Supabase Authentication > Users में user disable/delete करें।
- Supabase service_role/secret key को कभी website JavaScript, GitHub या Vercel public environment में न रखें।
- यह शुरुआती CMS है: rich text editor, blog comments, automatic sitemap regeneration और SEO social image अभी शामिल नहीं हैं।
- Blog article content plain text है; paragraphs के लिए blank line दें।
- Image upload limit 3 MB है; JPG/PNG/WebP।

पहले testing के लिए एक test blog Draft में save करें, फिर publish करें और homepage + article page check करें।
