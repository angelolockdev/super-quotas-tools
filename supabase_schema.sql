-- SUPABASE SCHEMA FOR COCKPIT TOOLS
-- Run this in your Supabase SQL Editor to set up the necessary tables.
-- 1. Accounts Table
CREATE TABLE IF NOT EXISTS public.accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    platform TEXT NOT NULL,
    email TEXT NOT NULL,
    display_name TEXT,
    plan TEXT DEFAULT 'unknown',
    tags TEXT [] DEFAULT '{}',
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    last_used_at TIMESTAMPTZ,
    -- Ensure platform is one of the supported types
    CONSTRAINT platform_check CHECK (
        platform IN (
            'anthropic',
            'openai',
            'github',
            'windsurf',
            'codeium',
            'cursor'
        )
    )
);
-- 2. Quotas Table
CREATE TABLE IF NOT EXISTS public.quotas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES public.accounts(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    label TEXT NOT NULL,
    used FLOAT8 DEFAULT 0,
    "limit" FLOAT8 DEFAULT 0,
    reset_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotas ENABLE ROW LEVEL SECURITY;
-- 4. Policies for Accounts
CREATE POLICY "Users can view their own accounts" ON public.accounts FOR
SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own accounts" ON public.accounts FOR
INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own accounts" ON public.accounts FOR
UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own accounts" ON public.accounts FOR DELETE USING (auth.uid() = user_id);
-- 5. Policies for Quotas (linked via account_id)
CREATE POLICY "Users can view quotas of their own accounts" ON public.quotas FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM public.accounts
            WHERE public.accounts.id = public.quotas.account_id
                AND public.accounts.user_id = auth.uid()
        )
    );
-- 6. Trigger for updated_at on quotas
CREATE OR REPLACE FUNCTION update_modified_column() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = now();
RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER update_quotas_modtime BEFORE
UPDATE ON public.quotas FOR EACH ROW EXECUTE PROCEDURE update_modified_column();