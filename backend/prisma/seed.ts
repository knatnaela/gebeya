import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { notificationService } from '../src/services/notification.service';
import { seedFeatures } from './seeds/features.seed';

// Use UserRole enum - will be available after prisma generate
// For now, we'll use the enum values directly as strings

const prisma = new PrismaClient();

// Generate a cuid-like ID
const generateId = () => {
  const timestamp = Date.now().toString(36);
  const randomStr = Math.random().toString(36).substring(2, 15);
  return `cl${timestamp}${randomStr}`;
};

async function main() {
  console.log('🌱 Seeding database...');

  // Seed features first
  console.log('📦 Seeding features...');
  try {
    await seedFeatures();
    console.log('✅ Features seeded successfully');
  } catch (error) {
    console.warn('⚠️  Failed to seed features:', error);
  }

  // Create platform owner company
  const company = await prisma.companies.upsert({
    where: { email: 'admin@gebeya.com' },
    update: {},
    create: {
      id: generateId(),
      name: 'Gebeya Platform',
      email: 'admin@gebeya.com',
      updatedAt: new Date(),
    },
  });

  // Create platform owner user
  const platformOwnerPassword = 'admin123';
  const hashedPassword = await bcrypt.hash(platformOwnerPassword, 10);
  const platformOwner = await prisma.users.upsert({
    where: { email: 'admin@gebeya.com' },
    update: {},
    create: {
      id: generateId(),
      email: 'admin@gebeya.com',
      password: hashedPassword,
      firstName: 'Platform',
      lastName: 'Owner',
      role: 'PLATFORM_OWNER' as const,
      companyId: company.id,
      updatedAt: new Date(),
    },
  });

  // Create default Super Admin role for platform owners with all features
  console.log('👑 Creating default Super Admin role...');
  const allPlatformFeatures = await prisma.features.findMany({
    where: { type: 'PLATFORM_OWNER' },
  });

  let superAdminRole = await prisma.roles.findFirst({
    where: {
      name: 'Super Admin',
      type: 'PLATFORM_OWNER',
      isSystemRole: true,
    },
  });

  if (!superAdminRole) {
    superAdminRole = await prisma.roles.create({
      data: {
        id: generateId(),
        name: 'Super Admin',
        description: 'Full access to all platform owner features',
        type: 'PLATFORM_OWNER',
        hierarchyLevel: 3,
        isSystemRole: true,
        companyId: null, // Platform-wide role
        createdBy: platformOwner.id,
        updatedAt: new Date(),
      },
    });
  }

  // Assign ALL features (both PLATFORM_OWNER and MERCHANT) to Super Admin role
  // Platform owners should have access to everything
  const allFeatures = await prisma.features.findMany();

  if (allFeatures.length > 0) {
    const roleFeatures = allFeatures.map((feature: any) => ({
      id: generateId(),
      roleId: superAdminRole.id,
      featureId: feature.id,
      actions: feature.isPageLevel ? [] : (feature.defaultActions as string[] || []),
    }));

    // Delete existing assignments and create new ones
    await prisma.role_features.deleteMany({
      where: { roleId: superAdminRole.id },
    });

    await prisma.role_features.createMany({
      data: roleFeatures,
      skipDuplicates: true,
    });
    console.log(`✅ Assigned ${allFeatures.length} features (all types) to Super Admin role`);
  }

  // Assign Super Admin role to platform owner
  await prisma.user_role_assignments.upsert({
    where: {
      userId_roleId: {
        userId: platformOwner.id,
        roleId: superAdminRole.id,
      },
    },
    update: {
      isActive: true,
      assignedBy: platformOwner.id,
      assignedAt: new Date(),
    },
    create: {
      id: generateId(),
      userId: platformOwner.id,
      roleId: superAdminRole.id,
      assignedBy: platformOwner.id,
      isActive: true,
    },
  });
  console.log('✅ Assigned Super Admin role to platform owner');

  // Send welcome email to platform owner with password
  try {
    await notificationService.sendWelcomeEmail({
      email: platformOwner.email,
      firstName: platformOwner.firstName,
      password: platformOwnerPassword,
      role: 'Platform Owner',
    });
    console.log('✅ Welcome email sent to platform owner');
  } catch (error) {
    console.warn('⚠️  Failed to send welcome email (this is OK if Resend is not configured):', error);
  }

  // Create sample merchant
  const merchant = await prisma.merchants.upsert({
    where: { email: 'merchant@example.com' },
    update: {},
    create: {
      id: generateId(),
      name: 'Sample Perfume Store',
      email: 'merchant@example.com',
      phone: '+1234567890',
      address: '123 Main St, City, Country',
      companyId: company.id,
      updatedAt: new Date(),
    },
  });

  // Create merchant admin
  const merchantAdminPasswordPlain = 'merchant123';
  const merchantAdminPassword = await bcrypt.hash(merchantAdminPasswordPlain, 10);
  const merchantAdmin = await prisma.users.upsert({
    where: { email: 'merchant@example.com' },
    update: {},
    create: {
      id: generateId(),
      email: 'merchant@example.com',
      password: merchantAdminPassword,
      firstName: 'Merchant',
      lastName: 'Admin',
      role: 'MERCHANT_ADMIN' as const,
      merchantId: merchant.id,
      updatedAt: new Date(),
    },
  });

  // Create default Merchant Admin role with all merchant features
  console.log('👑 Creating default Merchant Admin role...');
  const allMerchantFeatures = await prisma.features.findMany({
    where: { type: 'MERCHANT' },
  });

  let merchantAdminRole = await prisma.roles.findFirst({
    where: {
      name: 'Merchant Admin',
      type: 'MERCHANT',
      isSystemRole: true,
    },
  });

  if (!merchantAdminRole) {
    merchantAdminRole = await prisma.roles.create({
      data: {
        id: generateId(),
        name: 'Merchant Admin',
        description: 'Full access to all merchant features',
        type: 'MERCHANT',
        hierarchyLevel: 2,
        isSystemRole: true,
        companyId: null, // Platform-wide role
        createdBy: platformOwner.id,
        updatedAt: new Date(),
      },
    });
  }

  // Assign all merchant features to Merchant Admin role
  if (allMerchantFeatures.length > 0) {
    const roleFeatures = allMerchantFeatures.map((feature: any) => ({
      id: generateId(),
      roleId: merchantAdminRole.id,
      featureId: feature.id,
      actions: feature.isPageLevel ? [] : (feature.defaultActions as any || []),
    }));

    // Delete existing assignments and create new ones
    await prisma.role_features.deleteMany({
      where: { roleId: merchantAdminRole.id },
    });

    await prisma.role_features.createMany({
      data: roleFeatures,
      skipDuplicates: true,
    });
    console.log(`✅ Assigned ${allMerchantFeatures.length} features to Merchant Admin role`);
  }

  // Assign Merchant Admin role to merchant admin user
  await prisma.user_role_assignments.upsert({
    where: {
      userId_roleId: {
        userId: merchantAdmin.id,
        roleId: merchantAdminRole.id,
      },
    },
    update: {
      isActive: true,
      assignedBy: platformOwner.id,
      assignedAt: new Date(),
    },
    create: {
      id: generateId(),
      userId: merchantAdmin.id,
      roleId: merchantAdminRole.id,
      assignedBy: platformOwner.id,
      isActive: true,
    },
  });
  console.log('✅ Assigned Merchant Admin role to merchant admin user');

  // Create default location for merchant
  console.log('📍 Creating default location for merchant...');
  const defaultLocation = await prisma.locations.upsert({
    where: {
      merchantId_name: {
        merchantId: merchant.id,
        name: 'Main Warehouse',
      },
    },
    update: {
      isDefault: true,
      isActive: true,
    },
    create: {
      id: generateId(),
      merchantId: merchant.id,
      name: 'Main Warehouse',
      isDefault: true,
      isActive: true,
    },
  });
  console.log('✅ Created default location for merchant');

  // Send welcome email to merchant admin with password
  try {
    await notificationService.sendWelcomeEmail({
      email: merchantAdmin.email,
      firstName: merchantAdmin.firstName,
      password: merchantAdminPasswordPlain,
      role: 'Merchant Admin',
    });
    console.log('✅ Welcome email sent to merchant admin');
  } catch (error) {
    console.warn('⚠️  Failed to send welcome email (this is OK if Resend is not configured):', error);
  }

  console.log('✅ Seeding completed!');
  console.log('Platform Owner:', platformOwner.email);
  console.log('Merchant Admin:', merchantAdmin.email);
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

